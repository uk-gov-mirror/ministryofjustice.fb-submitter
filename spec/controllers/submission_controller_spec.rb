require 'rails_helper'

RSpec.describe SubmissionController, type: :controller do
  before do
    request.env['CONTENT_TYPE'] = 'application/json'
    request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials('', ENV['AUTH_BASIC_PASSWORD'])
  end

  it 'creates a submission' do
    post :create, body: { something: 1 }.to_json

    expect(Submission.all.count).to eq(1)
  end

  it 'saves the payload into the submission' do
    payload = { actions: 1, submission: { else: 1 }, attachments: [1, 2] }
    post :create, body: payload.to_json

    expect(Submission.first.payload).to eq(payload.deep_stringify_keys)
  end

  it 'creates a delayed job' do
    post :create, body: { something: 1 }.to_json
    expect(Delayed::Job.all.count).to eq(1)
  end

  it 'marks delayed job as created' do
    post :create, body: { something: 1 }.to_json
    expect(response).to have_http_status(:created)
  end
end
