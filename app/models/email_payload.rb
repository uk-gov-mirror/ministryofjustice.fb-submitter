class EmailPayload < ActiveRecord::Base
  def decrypted_attachments
    EncryptionService.new.decrypt(attachments)
  end

  def decrypted_to
    EncryptionService.new.decrypt(to)
  end
end
