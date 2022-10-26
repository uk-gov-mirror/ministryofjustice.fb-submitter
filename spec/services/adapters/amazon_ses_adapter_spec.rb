require 'rails_helper'

describe Adapters::AmazonSESAdapter do
  before do
    allow(Aws::SESV2::Client).to receive(:new).with(region: 'eu-west-1').and_return(stub_aws)
  end

  let(:stub_aws) do
    Aws::SESV2::Client.new(region: 'eu-west-1', stub_responses: true)
  end

  it 'returns the response given the correct params' do
    expect(described_class.send_mail(to: '', raw_message: '', from: '').to_h).to eq(message_id: 'OutboundMessageId')
  end
end
