class EmailOutputService
  def initialize(email_service:)
    @email_service = email_service
  end

  def execute(submission_id:, action:, attachments:, pdf_attachment:)
    email_attachments = []

    if action.fetch(:include_attachments) == true
      email_attachments = email_attachments.concat attachments
    end
    if action.fetch(:include_pdf) == true
      email_attachments << pdf_attachment
    end

    if email_attachments.empty?
      send_single_email(
        action: action,
        attachments: [],
        subject: subject(
          subject: action.fetch(:subject),
          current_email: 1,
          number_of_emails: 1,
          submission_id: submission_id
        )
      )
    else
      send_emails_with_attachments(action, email_attachments, submission_id: submission_id)
    end
  end

  private

  def send_emails_with_attachments(action, email_attachments, submission_id:)
    email_attachments.each_with_index do |email_attachment, index|
      send_single_email(
        action: action,
        attachments: [email_attachment],
        subject: subject(
          subject: action.fetch(:subject),
          current_email: index + 1,
          number_of_emails: email_attachments.size,
          submission_id: submission_id
        )
      )
    end
  end

  def send_single_email(subject:, action:, attachments:)
    email_service.send_mail(
      from: action.fetch(:from),
      to: action.fetch(:to),
      subject: subject,
      body_parts: email_body_parts(action.fetch(:email_body)),
      attachments: attachments
    )
  end

  def subject(subject:, current_email:, number_of_emails:, submission_id:)
    "#{subject} {#{submission_id}} [#{current_email}/#{number_of_emails}]"
  end

  def email_body_parts(email_body)
    {
      'text/plain': email_body
    }
  end

  attr_reader :email_service
end
