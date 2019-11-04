class EmailOutputService
  def initialize(email_service:)
    @email_service = email_service
  end

  def execute(action:, attachments:, pdf_attachment:)
    email_attachments = []

    if action.fetch(:include_attachments) == true
      email_attachments = email_attachments.concat attachments
    end
    if action.fetch(:include_pdf) == true
      email_attachments << pdf_attachment
    end

    send_emails(action, email_attachments)
  end

  private

  def send_emails(action, email_attachments)
    loop do
      send_single_email(
        action: action,
        attachment: email_attachments.pop || []
      )

      break if email_attachments.size <= 0
    end
  end

  def send_single_email(action:, attachment:)
    email_service.send_mail(
      from: action.fetch(:from),
      to: action.fetch(:to),
      subject: action.fetch(:subject),
      body_parts: email_body_parts(action.fetch(:email_body)),
      attachments: attachment
    )
  end

  def email_body_parts(email_body)
    {
      'text/plain': email_body
    }
  end

  attr_reader :email_service
end
