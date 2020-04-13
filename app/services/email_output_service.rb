class EmailOutputService
  MAX_ATTACHMENTS_SIZE = 10_000_000 # 10MB in bytes. AWS SES limitation

  def initialize(emailer:)
    @emailer = emailer
  end

  def execute(submission_id:, action:, attachments:, pdf_attachment:)
    email_attachments = generate_attachments(action: action,
                                             attachments: attachments,
                                             pdf_attachment: pdf_attachment)

    if email_attachments.empty?
      send_single_email(
        action: action,
        subject: subject(subject: action.fetch(:subject), submission_id: submission_id)
      )
    else
      send_emails_with_attachments(action, email_attachments, submission_id: submission_id)
    end
  end

  private

  def generate_attachments(action:, attachments:, pdf_attachment:)
    email_attachments = []

    if action.fetch(:include_attachments, false)
      email_attachments = email_attachments.concat(by_size(attachments))
    end
    if action.fetch(:include_pdf, false)
      email_attachments.prepend(pdf_attachment)
    end

    attachments_per_email(email_attachments)
  end

  def by_size(attachments)
    attachments.sort_by { |attachment| attachment.size }
  end

  def sum(attachments, to_add)
    attachments.inject(0) { |sum, attachment| sum + attachment.size } + to_add.size
  end

  def attachments_per_email(attachments)
    all = []
    per_email = []

    attachments.each do |attachment|
      if sum(per_email, attachment) >= MAX_ATTACHMENTS_SIZE
        all << per_email
        attachment == attachments.last ? all << [attachment] : per_email = [attachment]
      else
        per_email << attachment
        all << per_email if attachment == attachments.last
      end
    end
    all
  end

  def send_emails_with_attachments(action, email_attachments, submission_id:)
    email_attachments.each_with_index do |attachments, index|
      send_single_email(
        action: action,
        attachments: attachments,
        subject: subject(
          subject: action.fetch(:subject),
          current_email: index + 1,
          number_of_emails: email_attachments.size,
          submission_id: submission_id
        )
      )
    end
  end

  def send_single_email(subject:, action:, attachments: [])
    emailer.send_mail(
      from: action.fetch(:from),
      to: action.fetch(:to),
      subject: subject,
      body_parts: email_body_parts(action.fetch(:email_body)),
      attachments: attachments
    )
  end

  def subject(submission_id:, subject:, current_email: 1, number_of_emails: 1)
    "#{subject} {#{submission_id}} [#{current_email}/#{number_of_emails}]"
  end

  def email_body_parts(email_body)
    {
      'text/plain': email_body
    }
  end

  attr_reader :emailer
end
