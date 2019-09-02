require 'rails_helper'
require 'webmock/rspec'

describe Adapters::RunnerCallback do
  let(:response) do
    { id: SecureRandom.uuid }
  end

  let(:expected_url) do
    "http://www.example.com/#{response}"
  end

  subject {
    described_class.new(url: expected_url)
  }

  it 'returns the submission json when given a url' do
    expected_url = "http://www.example.com/#{response}"
    stub_request(:get, expected_url).to_return(status: 200, body: response.to_json, headers: {})

    expect(subject.fetch_full_submission).to eq(response)

    expect(WebMock).to have_requested(:get, expected_url).once
  end

  it 'throws exception if not 200 response' do
    stub_request(:get, expected_url).to_return(status: 500)

    expect{
      subject.fetch_full_submission
    }.to raise_error(Adapters::RunnerCallback::FrontendRequestError)
  end
end
