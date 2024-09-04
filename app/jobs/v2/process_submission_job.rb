module V2
  class ProcessSubmissionJob < ApplicationJob
    queue_as :default

    attr_reader :request_id, :jwt_skew_override

    def perform(submission_id:, **options)
      @request_id = options[:request_id]
      @jwt_skew_override = options[:jwt_skew_override]

      Sentry.set_tags(request_id:)

      submission = Submission.find(submission_id)
      decrypted_submission = submission.decrypted_submission.merge('submission_id' => submission.id)
      payload_service = V2::SubmissionPayloadService.new(decrypted_submission)

      Sentry.set_context('attachments', { size: payload_service.attachments.size })

      decrypted_submission['actions'].each do |action|
        Sentry.set_context('action_payload', action.slice('kind', 'variant', 'include_attachments', 'include_pdf'))

        case action['kind']
        when 'json'
          JsonWebhookService.new(
            webhook_attachment_fetcher: WebhookAttachmentService.new(
              attachment_parser: AttachmentParserService.new(attachments: payload_service.attachments),
              user_file_store_gateway: Adapters::UserFileStore.new(key: submission.encrypted_user_id_and_token, request_id:)
            ),
            webhook_destination_adapter: Adapters::JweWebhookDestination.new(
              url: action['url'],
              key: action['key']
            )
          ).execute(
            user_answers: payload_service.user_answers,
            service_slug: submission.service_slug,
            payload_submission_id: payload_service.submission_id
          )
        when 'email'
          attachments = []
          pdf_attachment = nil

          if action['include_pdf'] == true
            pdf_api_gateway = Adapters::PdfApi.new(
              root_url: ENV.fetch('PDF_GENERATOR_ROOT_URL'),
              token: submission.access_token,
              request_id:
            )
            pdf_attachment = GeneratePdfContent.new(
              pdf_api_gateway:,
              payload: PdfPayloadTranslator.new(decrypted_submission).to_h
            ).execute
          end

          if action['include_attachments'] == true
            attachments = download_attachments(
              decrypted_submission['attachments'],
              submission.encrypted_user_id_and_token,
              submission.access_token
            )
          end

          send_email(submission:, action:, attachments:, pdf_attachment:)
        when 'csv'
          csv_attachment = V2::GenerateCsvContent.new(payload_service:).execute

          send_email(submission:, action:, attachments: [csv_attachment])
        when 'mslist'
          ms_graph_adapter(action, submission.service_slug)

          if action['include_attachments'] == true
            attachments = download_attachments(
              decrypted_submission['attachments'],
              submission.encrypted_user_id_and_token,
              submission.access_token
            )

            created_folder = create_folder_in_drive(submission.id)
            uploaded_files = []

            attachments.each do |attachment|
              response = send_attachment_to_drive(attachment, submission.id, created_folder)
              uploaded_files << {
                'filename' => attachment.filename,
                'ms_url' => response['webUrl']
              }
            end

            uploaded_files.each do |file|
              decrypted_submission['pages'].each do |page|
                page['answers'].each do |answer|
                  next unless answer['field_id'].match?(/upload/) || answer['field_id'].match?(/multiupload/)

                  # replace filename with link in answer, use gsub so it works on multiupload answers
                  answer['answer'] = answer['answer'].gsub(file['filename'], rich_text_link_for_file(file['filename'], file['ms_url']))
                end
              end
            end
          end

          post_to_ms_list(decrypted_submission, submission.id)
        else
          Rails.logger.warn "Unknown action type '#{action}' for submission id #{submission.id}"
        end
      end
    end

    def rich_text_link_for_file(filename, url)
      "<a href=\"#{url}\">#{filename}</a>"
    end

    def download_attachments(attachments, encrypted_user_id_and_token, access_token)
      DownloadAttachments.new(
        attachments:,
        encrypted_user_id_and_token:,
        access_token:,
        request_id:,
        jwt_skew_override:
      ).download
    end

    def send_email(submission:, action:, attachments:, pdf_attachment: nil)
      EmailOutputService.new(
        emailer: EmailService,
        attachment_generator: AttachmentGenerator.new,
        encryption_service: EncryptionService.new,
        submission_id: submission.id,
        payload_submission_id: submission.id
      ).execute(
        action: action.symbolize_keys,
        attachments:,
        pdf_attachment:
      )
    end

    delegate :send_attachment_to_drive, :post_to_ms_list, :create_folder_in_drive, to: :ms_graph_adapter

    def ms_graph_adapter(action = nil, service_slug = nil)
      @ms_graph_adapter ||= V2::SendToMsGraphService.new(action, service_slug)
    end
  end
end
