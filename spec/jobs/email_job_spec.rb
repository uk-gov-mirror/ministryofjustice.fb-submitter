require 'rails_helper'

describe EmailJob do
  describe '#perform' do
    let(:mock_client) { double('client') }
    let(:to) { 'user@example.com' }
    let(:email_subject) { 'subject goes here' }
    let(:body) { 'saved form at https://example.com' }
    let(:email) do
      {
        to: to,
        subject: email_subject,
        body: body,
        template_name: 'email.generic'
      }
    end
    let(:template_id) { '46a72b64-9541-4000-91a7-fa8a3fa10bf9' }

    it 'sends email' do
      expect(Notifications::Client).to receive(:new).and_return(mock_client)
      expect(mock_client).to receive(:send_email).with(email_address: to,
                                                       template_id: template_id,
                                                       personalisation: {
                                                         subject: email_subject,
                                                         body: body,
                                                       })

      subject.perform(email: email)
    end
  end
end
