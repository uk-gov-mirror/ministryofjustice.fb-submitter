require 'rails_helper'

describe SaveReturn::EmailConfirmationsController, :active do
  before :each do
    allow_any_instance_of(ApplicationController).to receive(:verify_token!)
  end

  let(:email) { 'recipient@example.com' }
  let(:confirmation_link) { 'https://example.com/foo' }

  describe 'POST #create' do
    it 'enqueues job' do
      expect do
        post :create
      end.to change { ActiveJob::Base.queue_adapter.enqueued_jobs.size }.by(1)
    end

    it 'sets job params correctly' do
      expect do
        post :create, params: { email: email, confirmation_link: confirmation_link }
      end.to have_enqueued_job(SaveReturnEmailConfirmationJob).with(email: email, confirmation_link: confirmation_link)
    end

    it 'returns 201' do
      post :create, params: { email: email, confirmation_link: confirmation_link }
      expect(response).to be_created
    end
  end
end
