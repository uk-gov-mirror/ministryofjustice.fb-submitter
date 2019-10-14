class SendConfirmationEmail
  def initialize(email_service:, save_temp_pdf_service:)
    @email_service = email_service
    @save_temp_pdf_service = save_temp_pdf_service
  end

  def execute(from:, to:, subject:, submission_id:)
    temp_pdf_file = save_temp_pdf_service.execute(file_name: submission_id)

    email_service.send_mail(
      from: from,
      to: to,
      subject: subject,
      attachments: [temp_pdf_file]
    )
  end

  private

  attr_reader :email_service, :save_temp_pdf_service
end
