class JsonWebhookService
  def initialize(webhook_attachment_fetcher:, webhook_destination_adapter:)
    @webhook_attachment_fetcher = webhook_attachment_fetcher
    @webhook_destination_adapter = webhook_destination_adapter
  end

  def execute(user_answers:, service_slug:)
    webhook_destination_adapter.send_webhook(
      body: build_payload(
        user_answers: user_answers,
        service_slug: service_slug,
        attachments: webhook_attachment_fetcher.execute
      )
    )
  end

  private

  attr_reader :webhook_destination_adapter, :webhook_attachment_fetcher

  def build_payload(service_slug:, attachments:, user_answers:)
    {
      "serviceSlug": service_slug,
      "submissionId": user_answers['submissionId'],
      "submissionAnswers": user_answers.except('submissionId'),
      "attachments": attachments
    }.to_json
  end
end
