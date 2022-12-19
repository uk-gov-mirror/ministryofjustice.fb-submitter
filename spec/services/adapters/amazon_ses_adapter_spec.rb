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

  context 'when sending email payload' do
    let(:to_address) { 'someaddress' }
    let(:from_address) { 'someaddress' }
    let(:email_body) { 'email body' }
    let(:opts) do
      {
        to: to_address,
        from: from_address,
        raw_message: double(to_s: email_body) # rubocop:disable RSpec/VerifiedDoubles
      }
    end
    let(:expected_payload) do
      {
        from_email_address: Adapters::AmazonSESAdapter::DEFAULT_FROM_ADDRESS,
        destination: {
          to_addresses: [to_address]
        },
        reply_to_addresses: expected_reply_to_addresses,
        content: {
          raw: {
            data: email_body
          }
        }
      }
    end

    # rubocop:disable RSpec/MessageSpies
    context 'when from address is different to moj forms default address' do
      let(:expected_reply_to_addresses) { [from_address] }

      it 'uses the supplied from address as the reply to address' do
        expect(stub_aws).to receive(:send_email).with(expected_payload)
        described_class.send_mail(opts)
      end
    end

    context 'when from address is the same as moj forms default address' do
      let(:from_address) { Adapters::AmazonSESAdapter::DEFAULT_FROM_ADDRESS }
      let(:expected_reply_to_addresses) { [] }

      it 'does not set a reply to address' do
        expect(stub_aws).to receive(:send_email).with(expected_payload)
        described_class.send_mail(opts)
      end
    end

    context 'when the from address is not present' do
      let(:from_address) { nil }
      let(:expected_reply_to_addresses) { [] }

      it 'does not set a reply to address' do
        expect(stub_aws).to receive(:send_email).with(expected_payload)
        described_class.send_mail(opts)
      end
    end
    # rubocop:enable RSpec/MessageSpies
  end
end
