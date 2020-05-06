class EmailPayload < ActiveRecord::Base
  def decrypted_attachments
    EncryptionService.new.decrypt(attachments)
  end
end
