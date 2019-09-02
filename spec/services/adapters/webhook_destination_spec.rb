require 'rails_helper'
require 'webmock/rspec'

describe Adapters::WebhookDestination do

  let(:payload) do
    { id: SecureRandom.uuid }
  end

  let(:expected_url) do
    "http://www.example.com/#{SecureRandom.uuid}"
  end

  subject {
    described_class.new(url: expected_url)
  }

  it 'makes a post to the given url' do
    stub_request(:post, expected_url).to_return(status: 200)

    subject.send_webhook(body: payload)

    expect(WebMock).to have_requested(:post, expected_url).with(body: payload).once
  end

  it 'throws exception if not 200 response' do
    stub_request(:post, expected_url).with(body: payload).to_return(status: 500)

    expect{
      subject.send_webhook(body: payload)
    }.to raise_error(Adapters::WebhookDestination::DestinationRequestError)
  end
end
