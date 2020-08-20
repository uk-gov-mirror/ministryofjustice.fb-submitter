require 'rails_helper'

RSpec.describe SubmissionController, type: :controller do
  let(:submission_decryption_key) { '58992847-4155-4c' }
  let(:submission) do
    {
      meta: {
        submission_id: '123',
        submission_at: '2019-12-18T13:19:29.626Z'
      },
      actions: 1,
      submission: { submission_id: '123', else: 1 },
      attachments: [1, 2]
    }
  end
  let(:encrypted_submission) do
    JWE.encrypt(
      JSON.generate(submission),
      submission_decryption_key,
      alg: 'dir'
    )
  end
  let(:payload) do
    {
      service_slug: 'service-slug',
      encrypted_user_id_and_token: 'encrypted-token',
      encrypted_submission: encrypted_submission
    }
  end
  let(:headers) do
    {
      'content-type' => 'application/json',
      'x-access-token-v2' => token
    }
  end
  let(:token) { 'some-access-token' }

  context 'with encrypted payload' do
    before do
      allow(controller).to receive(:submission_decryption_key)
        .and_return(submission_decryption_key)
      request.headers.merge!(headers)
      allow_any_instance_of(ApplicationController).to receive(:verify_token!)
      post :create, body: payload.to_json, format: :json
    end

    after do
      Submission.destroy_all
    end

    it 'creates a submission' do
      expect(Submission.all.count).to eq(1)
    end

    it 'persists access token' do
      expect(Submission.first.access_token).to eq(token)
    end

    it 'saves the payload into the submission' do
      expect(Submission.first.decrypted_payload).to eq(
        ActiveSupport::HashWithIndifferentAccess.new(submission)
      )
    end

    it 'creates a delayed job' do
      expect(Delayed::Job.all.count).to eq(1)
    end

    it 'marks delayed job as created' do
      expect(response).to have_http_status(:created)
    end

    it 'returns valid json response' do
      expect { JSON.parse(response.body) }.not_to raise_error
    end
  end

  context 'with old payload' do
    let(:old_payload) do
      {
        service_slug: 'service-slug',
        encrypted_user_id_and_token: 'encrypted-token'
      }.merge(submission)
    end

    before do
      request.headers.merge!(headers)
      allow_any_instance_of(ApplicationController).to receive(:verify_token!)
      post :create, body: old_payload.to_json, format: :json
    end

    after do
      Submission.destroy_all
    end

    it 'saves the older style payload into the submission' do
      expect(Submission.first.decrypted_payload).to eq(
        ActiveSupport::HashWithIndifferentAccess.new(submission)
      )
    end
  end
end
