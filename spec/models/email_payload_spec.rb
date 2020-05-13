require 'rails_helper'

RSpec.describe EmailPayload do
  describe 'decrypted_payload' do
    let(:submission) { create(:submission) }
    let(:attachments) { %w[call me ishmael] }
    let(:to) { 'ahab@pequod.boat' }
    let(:encrypted_to) { EncryptionService.new.encrypt(to) }
    let(:encrypted_attachments) { EncryptionService.new.encrypt(attachments) }

    let(:email_payload) do
      described_class.create!(
        submission_id: submission.id,
        to: encrypted_to,
        attachments: encrypted_attachments
      )
    end

    it 'decrypts the attachments' do
      expect(email_payload.decrypted_attachments).to eq(attachments)
    end

    it 'decrypts the to' do
      expect(email_payload.decrypted_to).to eq(to)
    end
  end
end
