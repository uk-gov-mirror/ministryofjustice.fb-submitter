require 'rails_helper'

RSpec.describe EmailPayload do
  describe 'decrypted_payload' do
    let(:attachments) { %w[call me ishmael] }
    let(:encrypted_attachments) { EncryptionService.new.encrypt(attachments) }

    let(:email_payload) { described_class.create!(attachments: encrypted_attachments) }

    it 'decrypts the attachments' do
      expect(email_payload.decrypted_attachments).to eq(attachments)
    end
  end
end
