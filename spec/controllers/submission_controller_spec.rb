require 'rails_helper'

RSpec.describe SubmissionController, type: :controller do
  let(:payload) do
    {
      meta: {
        submission_id: '123',
        submission_at: '2019-12-18T13:19:29.626Z'
      },
      actions: 1,
      submission: {
        submission_id: '123',
        else: 1
      },
      attachments: [1, 2]
    }
  end

  before do
    request.env['CONTENT_TYPE'] = 'application/json'
    allow_any_instance_of(ApplicationController).to receive(:verify_token!)
    post :create, body: payload.to_json
  end

  it 'creates a submission' do
    expect(Submission.all.count).to eq(1)
  end

  it 'saves the payload into the submission' do
    expect(Submission.first.decrypted_payload).to eq(payload.deep_stringify_keys)
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
