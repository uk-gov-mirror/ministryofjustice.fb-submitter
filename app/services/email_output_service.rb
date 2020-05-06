class EmailOutputService
  def initialize(emailer:, attachment_generator:, encryption_service:)
    @emailer = emailer
    @attachment_generator = attachment_generator
    @encryption_service = encryption_service
  end

  def execute(submission_id:, action:, attachments:, pdf_attachment:)
    attachment_generator.execute(
      action: action,
      attachments: attachments,
      pdf_attachment: pdf_attachment
    )

    if attachment_generator.sorted_attachments.empty?
      send_single_email(
        action: action,
        subject: subject(subject: action.fetch(:subject), submission_id: submission_id),
        submission_id: submission_id
      )
    else
      send_emails_with_attachments(
        action,
        attachment_generator.sorted_attachments,
        submission_id: submission_id
      )
    end
  end

  private

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
        ),
        submission_id: submission_id
      )
    end
  end

  def send_single_email(subject:, action:, attachments: [], submission_id:)
    email_payload = find_or_create_email_payload(submission_id, attachments)

    if email_payload.succeeded_at.nil? # rubocop:disable Style/GuardClause
      emailer.send_mail(
        from: action.fetch(:from),
        to: action.fetch(:to),
        subject: subject,
        body_parts: email_body_parts(action.fetch(:email_body)),
        attachments: attachments
      )

      email_payload.update(succeeded_at: Time.now)
    end
  end

  def subject(submission_id:, subject:, current_email: 1, number_of_emails: 1)
    "#{subject} {#{submission_id}} [#{current_email}/#{number_of_emails}]"
  end

  def email_body_parts(email_body)
    {
      'text/plain': email_body
    }
  end

  def find_or_create_email_payload(submission_id, attachments)
    filenames = attachments.map(&:filename).sort
    email_payload = EmailPayload.where(submission_id: submission_id)
                                .find { |payload| payload.decrypted_attachments == filenames }

    email_payload || EmailPayload.create(submission_id: submission_id,
                                         attachments: encryption_service.encrypt(filenames))
  end

  attr_reader :emailer, :attachment_generator, :encryption_service
end
