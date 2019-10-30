class ProcessSubmissionService # rubocop:disable  Metrics/ClassLength
  attr_reader :submission_id

  def initialize(submission_id:)
    @submission_id = submission_id
  end

  # rubocop:disable Metrics/MethodLength
  def perform # rubocop:disable Metrics/AbcSize
    submission.update_status(:processing)
    submission.responses = []

    payload_service = SubmissionPayloadService.new(submission.payload)
    payload_service.actions.each do |action|
      case action.fetch(:type)
      when 'json'
        JsonWebhookService.new(
          webhook_attachment_fetcher: WebhookAttachmentService.new(
            attachment_parser: AttachmentParserService.new(attachments: payload_service.attachments),
            user_file_store_gateway: Adapters::UserFileStore.new(key: submission.encrypted_user_id_and_token)
          ),
          webhook_destination_adapter: Adapters::JweWebhookDestination.new(
            url: action.fetch(:url),
            key: action.fetch(:encryption_key)
          )
        ).execute(submission: payload_service.submission, service_slug: submission.service_slug)
      when 'email'
        send_email(action, payload_service)
      else
        Rails.logger.warn "Unknown action type '#{action.fetch(:type)}' for submission id #{submission.id}"
      end
    end

    # explicit save! first, to save the responses
    submission.save!
    submission.complete!
  end

  private

  def email_body_parts(email)
    {
      'text/plain' => email.email_body
    }
  end

  def send_email(action, payload_service)
    if number_of_attachments(payload_service) <= 1
      attachment = payload_service.attachments.first
      response = EmailService.send_mail(
        from: action.from,
        to: action.to,
        subject: action.subject,
        body_parts: action.email_body,
        attachments: attachments(mail)
      )

      submission.responses << response.to_h
    else
      attachments(payload_service.attachments, action).each_with_index do |a, n|
        response = EmailService.send_mail(
          from: action.from,
          to: action.to,
          subject: "#{action.subject} {#{submission_id}} [#{n + 1}/#{number_of_attachments(payload_service)}]",
          body_parts: action.email_body,
          attachments: [a]
        )

        submission.responses << response.to_h
      end
    end
  end
  # rubocop:enable Metrics/MethodLength

  def number_of_attachments(payload_service)
    payload_service.attachments.length
  end

  def submission
    @submission ||= Submission.find(submission_id)
  end

  def headers
    { 'x-encrypted-user-id-and-token' => submission.encrypted_user_id_and_token }
  end

  def attachments(attachments, action)
    attachment_objects = []

    attachments.each_with_index do |value, index|
      if action.fetch('include_pdf')
        pdf = generate_pdf({ submission: value[:pdf_data] }, @submission_id)
        pdf = Attachment.new(type:, filename:, url:, mimetype:, path:)
        attachment_objects[index].file =
      else
        response = download_attachments(attachments)
        attachment_objects[index].path = download_attachments[attachment_objects[index].url]
      end
    end
    pp attachment_objects
    attachment_objects
  end

  def download_attachments(attachments)
    @download_attachments ||= DownloadService.new(
      attachments: attachments,
      token: submission.encrypted_user_id_and_token,
      target_dir: nil
    ).download_in_parallel
  end

  def generate_pdf(pdf_detail, submission_id)
    SaveTempPdf.new(
      generate_pdf_content_service: GeneratePdfContent.new(
        pdf_api_gateway: pdf_gateway(submission.service_slug),
        payload: pdf_detail.with_indifferent_access
      ),
      tmp_file_gateway: Tempfile
    ).execute(file_name: submission_id)
  end

  def pdf_gateway(service_slug)
    Adapters::PdfApi.new(
      root_url: ENV.fetch('PDF_GENERATOR_ROOT_URL'),
      token: authentication_token(service_slug)
    )
  end

  def authentication_token(service_slug)
    return if disable_jwt?

    JwtAuthService.new(
      service_token_cache: Adapters::ServiceTokenCacheClient.new(
        root_url: ENV.fetch('SERVICE_TOKEN_CACHE_ROOT_URL')
      ),
      service_slug: service_slug
    ).execute
  end

  def disable_jwt?
    Rails.env.development?
  end
end
