class Submission < ActiveRecord::Base
  has_many :email_payloads, dependent: :destroy

  # V1 way of decrypting payload
  def decrypted_payload
    EncryptionService.new.decrypt(payload).to_h
  end

  # V2 way of decrypting payload
  def decrypted_submission
    SubmissionEncryption.new.decrypt(payload)
  end

  # @return true if can decrypt the submission in v2
  # @return false otherwise
  #
  def v2?
    decrypted_submission
    true
  rescue StandardError
    false
  end
end
