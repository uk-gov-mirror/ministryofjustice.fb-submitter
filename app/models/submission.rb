class Submission < ActiveRecord::Base
  has_many :email_payloads, dependent: :destroy

  def decrypted_payload
    EncryptionService.new.decrypt(payload).to_h
  end
end
