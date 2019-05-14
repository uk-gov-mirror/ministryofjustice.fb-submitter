require 'rails_helper'

describe SaveReturnEmailMagicLinkJob do
  describe '#perform' do
    let(:mock_client) { double('client') }
    let(:email) { 'recipient@example.com' }
    let(:template_id) { 'd6555ce9-53f3-4370-92da-595ab555d4f0' }
    let(:magic_link) { 'https://example.com/foo' }

    it 'sends email' do
      expect(Notifications::Client).to receive(:new).and_return(mock_client)
      expect(mock_client).to receive(:send_email).with(email_address: email,
                                                       template_id: template_id,
                                                       personalisation: { magic_link: magic_link })

      subject.perform(email: email,
                      magic_link: magic_link,
                      template_context: {})
    end

    context 'with template_context' do
      it 'passes as personalisation' do
        expect(Notifications::Client).to receive(:new).and_return(mock_client)
        expect(mock_client).to receive(:send_email).with(email_address: email,
                                                         template_id: template_id,
                                                         personalisation: {
                                                           magic_link: magic_link,
                                                           name: 'John'
                                                         })

        subject.perform(email: email,
                        magic_link: magic_link,
                        template_context: {
                          name: 'John',
                          magic_link: 'hijack'
                        })
      end
    end
  end
end
