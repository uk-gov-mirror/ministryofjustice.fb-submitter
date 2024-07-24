require 'rails_helper'

RSpec.describe V2::ReplayBatchSubmission do
  let(:subject) { described_class.new(date_from:, date_to:, service_slug:, new_destination_email:, resend_json:, resend_mslist:) }

  let(:date_from) { 3.days.ago.to_s }
  let(:date_to) { 1.days.ago.to_s }
  let(:service_slug) { 'my-service-slug' }
  let(:new_destination_email) { 'valid@justice.gov.uk' }
  let(:resend_json) { false }
  let(:resend_mslist) { false }

  VALID_DOMAINS =
    [
      'justice.gov.uk',
      'digital.justice.gov.uk',
      'cica.gov.uk',
      'ccrc.gov.uk',
      'judicialappointments.gov.uk',
      'judicialombudsman.gov.uk',
      'ospt.gov.uk',
      'gov.sscl.com',
      'hmcts.net'
    ]

  INVALID_DOMAINS =
    [
      'fake-justice.gov.uk',
      'digita.justice.gov.uk',
      'cico.gov.uk'
    ]

  TWENTY_EIGHT_DAYS_IN_SECONDS = 28*24*60*60

  describe '#call' do
    context 'when there are valid params' do
      it 'calls process submissions' do
        expect(subject).to receive(:process_submissions).and_return(true)
        subject.call
      end
    end

    context 'dates are invalid' do
      let(:date_from) { 1.days.ago.to_s }
      let(:date_to) { 3.days.ago.to_s }

      it 'does not call process submissions' do
        expect(subject).to_not receive(:process_submissions)
        subject.call
      end
    end

    context 'destination invalid' do
      let(:new_destination_email) { 'invalid@wrongdomain.gov.uk' }

      it 'does not call process submissions' do
        expect(subject).to_not receive(:process_submissions)
        subject.call
      end
    end
  end

  describe '#validate_dates' do
    context 'when dates are valid' do
      it 'returns true' do
        expect(subject.validate_dates).to be(true)
      end
    end

    context 'dates are valid but not sensible' do
      let(:date_from) { 1.days.ago.to_s }
      let(:date_to) { 2.days.ago.to_s }

      it 'returns false' do
        expect(subject.validate_dates).to be(false)
      end
    end

    context 'date_from could not be parsed' do
      let(:date_from) { 'NaN' }

      it 'throws date error' do
        expect { described_class.new(date_from:, date_to:, service_slug:, new_destination_email:) }.to raise_error(Date::Error)
      end
    end

    context 'date_to could not be parsed' do
      let(:date_to) { 'peanut' }

      it 'throws date error' do
        expect { described_class.new(date_from:, date_to:, service_slug:, new_destination_email:) }.to raise_error(Date::Error)
      end
    end

  end

  describe '#validate_destination' do
    context 'domain is on the allow list' do
      VALID_DOMAINS.each do |domain|
        let(:new_destination_email) { "hello@#{domain}" }

        it "returns valid for #{domain}" do
          expect(subject.validate_destination).to be(true)
        end
      end
    end

    context 'domain is not on the allow list' do
      INVALID_DOMAINS.each do |domain|
        let(:new_destination_email) { "hello@#{domain}" }

        it "returns valid for #{domain}" do
          expect(subject.validate_destination).to be(false)
        end
      end
    end
  end

  describe '#get_submissions_to_process' do
    context 'there are submissions' do
      before do
        create(:submission, created_at: Date.today.beginning_of_day, service_slug:)
        create(:submission, created_at: 2.days.ago, service_slug:)
        create(:submission, created_at: 2.days.ago, service_slug: 'another-form')
        create(:submission, created_at: 3.days.ago, service_slug:)
        create(:submission, created_at: 5.days.ago, service_slug:)
      end

      it 'retrieves submissions' do
        expect(Submission.count).to be(5)
        expect(subject.get_submissions_to_process.count).to be(2)
        expect(subject.get_submissions_to_process.first.service_slug).to eq(service_slug)
        expect(subject.get_submissions_to_process.last.service_slug).to eq(service_slug)
      end
    end

    context 'there are no submissions' do
      it 'returns empty' do
        expect(subject.get_submissions_to_process.count).to be(0)
      end
    end
  end

  describe '#process_submissions' do
    let(:access_token) { 'user_and_session_id' }
    let(:key) { SecureRandom.uuid[0..31] }
    let(:payload_fixture) do
      JSON.parse(File.read(Rails.root.join('spec/fixtures/payloads/valid_submission.json')))
    end
    let(:encrypted_payload) do
      fixture = payload_fixture
      fixture['actions'] << { 'kind' => 'email', 'variant' => 'confirmation' }
      SubmissionEncryption.new(key:).encrypt(fixture)
    end

    before do
      allow(ENV).to receive(:[])
      allow(ENV).to receive(:[]).with('SUBMISSION_DECRYPTION_KEY').and_return(key)
    end

    after do
      ActiveJob::Base.queue_adapter.enqueued_jobs = []
    end

    context 'no submissions in date range' do
      let(:reprocessed_submission) { create(:submission, payload: encrypted_payload, access_token:, created_at: 5.days.ago, service_slug:) }

      it 'enqueues no jobs' do
        old_id = reprocessed_submission.id # this also ensures rspec creates it before we process submisisons
        subject.process_submissions

        expect(Submission.all.count).to eq(1)

        expect {
          subject.process_submissions
        }.to change {
          ActiveJob::Base.queue_adapter.enqueued_jobs.count
        }.by 0

        expect {
          subject.process_submissions
        }.to change(Submission, :count).by(0)
      end
    end

    context 'there are submissions' do
      let(:reprocessed_submission) { create(:submission, payload: encrypted_payload, access_token:, created_at: 2.days.ago, service_slug:) }

      it 'duplicates the old submission' do
        old_id = reprocessed_submission.id # this also ensures rspec creates it before we process submisisons

        subject.process_submissions

        # select the cloned submission we expect irrespective of ordering
        new_submission = Submission.select { |s| s.id != old_id }.first

        expect(new_submission.decrypted_submission['actions'].find { |a| a['kind'] == 'email' }['to']).to eq(new_destination_email)
        expect(new_submission.decrypted_submission['actions'].find { |a| a['kind'] == 'csv' }['to']).to eq(new_destination_email)
      end

      it 'leaves the old submission intact' do
        old_id = reprocessed_submission.id # this also ensures rspec creates it before we process submisisons

        subject.process_submissions

        expect(reprocessed_submission.decrypted_submission['actions'].find { |a| a['kind'] == 'email' }['to']).to eq('captain.needa@star-destroyer.com,admiral.piett@star-destroyer.com')
        expect(reprocessed_submission.decrypted_submission['actions'].find { |a| a['kind'] == 'csv' }['to']).to eq('captain.needa@star-destroyer.com,admiral.piett@star-destroyer.com')
        expect(reprocessed_submission.decrypted_submission['actions'].count).to eq(5)
      end

      it 'discards other actions by default' do
        old_id = reprocessed_submission.id # this also ensures rspec creates it before we process submisisons

        subject.process_submissions

        # select the cloned submission we expect irrespective of ordering
        new_submission = Submission.select { |s| s.id != old_id }.first

        expect(new_submission.decrypted_submission['actions'].count).to eq(2)
      end

      context 'resending non email actions' do
        let(:resend_json) { true }
        let(:resend_mslist) { true }

        it 'can resend mslist and json actions if configured' do
          old_id = reprocessed_submission.id # this also ensures rspec creates it before we process submisisons

          subject.process_submissions

          # select the cloned submission we expect irrespective of ordering
          new_submission = Submission.select { |s| s.id != old_id }.first

          expect(new_submission.decrypted_submission['actions'].count).to eq(4)
        end
      end

      it 'enqueues a job for each submission' do
        old_id = reprocessed_submission.id # this also ensures rspec creates it before we process submisisons
        subject.process_submissions
        new_submission = Submission.select { |s| s.id != old_id }.first

        expect {
          subject.process_submissions
        }.to change {
          ActiveJob::Base.queue_adapter.enqueued_jobs.count
        }.by 1

        enqueued_job = ActiveJob::Base.queue_adapter.enqueued_jobs[0]

        expect(enqueued_job['arguments'][0]['submission_id']).to eq(new_submission.id)
        expect(enqueued_job['job_class']).to eq("V2::ProcessSubmissionJob")
        expect(enqueued_job['arguments'][0]['jwt_skew_override']).to eq(TWENTY_EIGHT_DAYS_IN_SECONDS)
      end
    end
  end
end

