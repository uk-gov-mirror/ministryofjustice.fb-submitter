class Submission < ActiveRecord::Base
  def decrypted_payload
    EncryptionService.new.decrypt(payload).to_h
  end
end
