class EmailOutputService < BaseEmailOutputService
  def raw_message
    RawMessage
  end

  def email_body_parts(email_body)
    {
      'text/plain': email_body
    }
  end
end
