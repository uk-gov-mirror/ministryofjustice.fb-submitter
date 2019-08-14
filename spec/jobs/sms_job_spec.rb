require 'rails_helper'

describe SmsJob do
  describe '#perform' do
    let(:mock_client) { double('client') }
    let(:to) { '07123456789' }
    let(:body) { 'Your code is 12345' }
    let(:sms) do
      {
        to: to,
        body: body,
        template_name: 'sms.generic'
      }
    end
    let(:template_id) { 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa' }

    it 'sends sms' do
      expect(Notifications::Client).to receive(:new).and_return(mock_client)
      expect(mock_client).to receive(:send_sms).with(phone_number: to,
                                                     template_id: template_id,
                                                     personalisation: {
                                                       body: body,
                                                     })

      subject.perform(sms: sms)
    end
  end
end
