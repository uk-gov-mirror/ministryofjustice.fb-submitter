require 'rails_helper'

RSpec.describe V2::ReplayBatchSubmission do
  let(:subject) { described_class.new(date_from:, date_to:, service_slug:, new_destination_email:) }

  let(:date_from) { 3.days.ago.to_s }
  let(:date_to) { 1.days.ago.to_s }
  let(:service_slug) { 'my-service-slug' }
  let(:new_destination_email) { 'valid@justice.gov.uk' }

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
    context 'there are submissions' do
      let(:reprocessed_submission) { create(:submission, created_at: 2.days.ago, service_slug:) }


      it 'duplicates the old submission' do
        old_id = reprocessed_submission.id
        subject.process_submissions
        new_submission = Submission.last

        expect(new_submission.submission_id).to_not eq(old_id)
        expect(new_submission.decrypted_payload['actions'][0]['to']).to be(new_destination_email)
        expect(V2::ProcessSubmissionJob)to receive(:perform_later).with(
          submission_id: new_id,
          jwt_skew_override: TWENTY_EIGHT_DAYS_IN_SECONDS
        )
      end
    end
  end
end

