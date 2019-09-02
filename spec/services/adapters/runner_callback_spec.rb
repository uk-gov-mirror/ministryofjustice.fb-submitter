require 'rails_helper'
require 'webmock/rspec'

describe Adapters::RunnerCallback do
  let(:response) do
    { id: SecureRandom.uuid }.to_json
  end

  let(:expected_url) do
    "http://www.example.com/#{SecureRandom.uuid}"
  end

  subject do
    described_class.new(url: expected_url)
  end

  it 'returns the submission json when given a url' do
    stub_request(:get, expected_url).to_return(status: 200, body: response, headers: {})

    expect(subject.fetch_full_submission).to eq(response)

    expect(WebMock).to have_requested(:get, expected_url).once
  end

  it 'throws exception if not 200 response' do
    stub_request(:get, expected_url).to_return(status: 500)

    expect do
      subject.fetch_full_submission
    end.to raise_error(Adapters::RunnerCallback::ClientRequestError)
  end
end
