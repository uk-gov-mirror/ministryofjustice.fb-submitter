require 'rails_helper'

RSpec.describe Submission do
  describe 'decrypted_payload' do
    let(:encrypted_payload) do
      'GmEKcG/J7NXDuJzwjvBrpOCp79b2KXt9DzvP--S3c+ifLNDezwVL3D--CNbzzIDKJXjDlxu7OvWQ6Q=='
    end

    let(:decrypted_payload) do
      { sensitive: 'data' }
    end

    let(:submission) { described_class.create!(payload: encrypted_payload) }

    it 'decrypts the payload' do
      expect(submission.decrypted_payload).to eq(decrypted_payload)
    end
  end
end
