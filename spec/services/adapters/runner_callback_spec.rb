require 'rails_helper'
require 'webmock/rspec'

describe Adapters::RunnerCallback do
  it 'makes a request to the runner'

  let(:response) do
    { id: SecureRandom.uuid }
  end

  it 'returns the submission json' do
    stub_request(:get, "http://www.example.com/").to_return(status: 200, body: response.to_json, headers: {})
    expect(subject.fetch_full_submission).to eq(response)

    expect(WebMock).to have_requested(:get, 'www.example.com').once
  end

  it 'throws exception if not 200 response' do
    stub_request(:get, "http://www.example.com/").to_return(status: 500)

    expect{
      subject.fetch_full_submission
    }.to raise_error(Adapters::RunnerCallback::FrontendRequestError)
  end
end
