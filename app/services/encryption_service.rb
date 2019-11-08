class EncryptionService
  KEY = ActiveSupport::KeyGenerator.new(
    ENV.fetch('ENCRYPTION_KEY')
  ).generate_key(
    ENV.fetch('ENCRYPTION_SALT'),
    ActiveSupport::MessageEncryptor.key_len
  ).freeze

  private_constant :KEY

  delegate :encrypt_and_sign, :decrypt_and_verify, to: :encryptor

  def encrypt(value)
    encrypt_and_sign(value)
  end

  def decrypt(value)
    decrypt_and_verify(value)
  end

  private

  def encryptor
    ActiveSupport::MessageEncryptor.new(KEY)
  end
end
