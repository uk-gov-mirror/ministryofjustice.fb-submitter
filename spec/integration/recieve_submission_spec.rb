require 'rails_helper'
require 'aws-sdk-ses'

describe 'Receives submission from runner' do

  before :each do
    allow_any_instance_of(ApplicationController).to receive(:disable_jwt?).and_return(true)

    allow(Aws::SES::Client).to receive(:new).and_return(Aws::SES::Client.new(stub_responses: true))

    Delayed::Worker.delay_jobs = false
  end

  after do
    Delayed::Worker.delay_jobs = true
  end

  it 'requests email with pdf payload from runner' do
    VCR.use_cassette('submitting_pdf') do

      post submission_path, params: {
          service_slug: 'some-slug',
          encrypted_user_id_and_token: 'bla bla',
          submission_details: [{
              'from' => 'some.one@example.com',
              'to' => 'WOBALUBADUBDUB@example.com',
              'subject' => 'mail subject',
              'type' => 'email',
              'body_parts' => {
                  'text/html' => 'https://tools.ietf.org/html/rfc2324',
                  'text/plain' => 'https://tools.ietf.org/rfc/rfc2324.txt'
              },
              'attachments' => [
                  {
                      'type' => 'output',
                      'mimetype' => 'application/pdf',
                      'url' => '/api/runner/pdf/default/guid1.pdf',
                      'filename' => 'form1'
                  }
              ]
          }]}


      expect(response.status).to eq(201)
    end
  end
end
