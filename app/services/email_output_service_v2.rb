class EmailOutputServiceV2 < BaseEmailOutputService
  def raw_message
    V2::RawMessage
  end

  def email_body_parts(email_body)
    {
      'text/plain': strip_tags(email_body),
      'text/html': email_body
    }
  end
end
