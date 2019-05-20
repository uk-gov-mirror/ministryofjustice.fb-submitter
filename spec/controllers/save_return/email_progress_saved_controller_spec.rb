require 'rails_helper'

describe SaveReturn::EmailProgressSavedController do
  before :each do
    request.env['CONTENT_TYPE'] = 'application/json'
    allow_any_instance_of(ApplicationController).to receive(:verify_token!)
  end

  let(:json_hash) do
    {
      email: {
        to: 'user@example.com',
        subject: 'subject goes here',
        body: 'form saved at https://example.com'
      }
    }
  end

  describe 'POST #create' do
    it 'enqueues job' do
      expect do
        post :create, body: json_hash.to_json
      end.to change { ActiveJob::Base.queue_adapter.enqueued_jobs.size }.by(1)
    end

    it 'returns 201' do
      post :create, body: json_hash.to_json
      expect(response).to be_created
    end

    it 'returns empty json object in body' do
      post :create, body: json_hash.to_json
      expect(response.body).to eql('{}')
    end
  end
end
