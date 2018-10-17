class ProcessSubmissionJob < ApplicationJob
  queue_as :default

  # This method will need refactoring once there are more
  # submissions types than just 'email'  (e.g. API calls)
  # BUT until then, we'd just be trying to second-guess
  # exactly how
  def perform(submission_id:)
    @submission = Submission.find(submission_id)
    headers = {
      'x-encrypted-user-id-and-token' => @submission.encrypted_user_id_and_token
    }
    @submission.update_status(:processing)
    url_resolver = Adapters::ServiceUrlResolver.new(
      service_slug: @submission.service_slug,
      environment_slug: ENV['FB_ENVIRONMENT_SLUG']
    )
    url_file_map = DownloadService.download_in_parallel(
      urls: url_resolver.ensure_absolute_urls(unique_attachment_urls),
      headers: headers
    )

    @submission.responses = []

    @submission.detail_objects.to_a.each do |mail|
      body_part_content = retrieve_mail_body_parts(mail, url_resolver, headers)
      attachment_files = attachment_file_paths(mail, url_file_map)

      response = EmailService.send_mail(
        from:         mail.from,
        to:           mail.to,
        subject:      mail.subject,
        body_parts:   body_part_content,
        attachments:  attachment_files
      )

      @submission.responses << response.to_h
    end

    # explicit save! first, to save the responses
    @submission.save!

    @submission.complete!
  end

  def attachment_file_paths(mail, url_file_map)
    mail.attachments.map{|url| url_file_map[url]}
  end

  def unique_attachment_urls(submission = @submission)
    submission.detail_objects.map do |detail|
      detail.attachments
    end.flatten.compact.sort.uniq
  end

  def retrieve_mail_body_parts(mail, url_resolver, headers)
    body_part_map = download_body_parts(mail, url_resolver, headers)
    read_downloaded_body_parts(mail, body_part_map)
  end

  def download_body_parts(mail, url_resolver, headers)
    DownloadService.download_in_parallel(
      urls: url_resolver.ensure_absolute_urls(mail.body_parts.values),
      headers: headers
    )
  end

  def read_downloaded_body_parts(mail, body_part_map)
    # we need to send the body parts as strings
    body_part_content = {}
    mail.body_parts.each do |type, url|
      body_part_content[type] = File.open(body_part_map[url]){|f| f.read}
    end
    body_part_content
  end

  def on_retryable_exception(error)
    logger.warn "RETRYABLE EXCEPTION! @submission #{@submission.inspect}"
    @submission.fail!(retryable: true) if @submission
    super
  end

  def on_non_retryable_exception(error)
    @submission.fail!(retryable: false) if @submission
    super
  end

end
