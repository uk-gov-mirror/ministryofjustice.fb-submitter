class SubmissionEncryption
  attr_reader :encrypted_submission, :cipher, :key, :iv

  def initialize(key: ENV['SUBMISSION_DECRYPTION_KEY'])
    @cipher = OpenSSL::Cipher.new('aes-256-ctr')
    @key = key
    @iv = @key[0..15]
  end

  def encrypt(submission)
    cipher.encrypt
    cipher.key = key
    cipher.iv = iv
    result = cipher.update(submission.to_json)
    result << cipher.final

    Base64.encode64 result
  end

  def decrypt(encrypted_submission)
    cipher.decrypt
    cipher.key = key
    cipher.iv = iv
    raw_decrypted_submission = cipher.update(
      Base64.decode64(encrypted_submission)
    )
    raw_decrypted_submission << cipher.final

    JSON.parse(raw_decrypted_submission)
  end
end
