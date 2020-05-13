class EmailPayload < ActiveRecord::Base
  belongs_to :submission

  def decrypted_attachments
    EncryptionService.new.decrypt(attachments)
  end

  def decrypted_to
    EncryptionService.new.decrypt(to)
  end
end
