require 'rails_helper'

describe SaveReturnEmailProgressSavedJob do
  describe '#perform' do
    let(:mock_client) { double('client') }
    let(:to) { 'user@example.com' }
    let(:email_subject) { 'subject goes here' }
    let(:body) { 'saved form at https://example.com' }
    let(:email) do
      {
        to: to,
        subject: email_subject,
        body: body
      }
    end
    let(:template_id) { 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa' }

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
