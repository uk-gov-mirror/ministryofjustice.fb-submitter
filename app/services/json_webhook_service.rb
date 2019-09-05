class JsonWebhookService
  def initialize(runner_callback_adapter:, webhook_destination_adapter:)
    @runner_callback_adapter = runner_callback_adapter
    @webhook_destination_adapter = webhook_destination_adapter
  end

  def execute()
    webhook_destination_adapter.send_webhook(body: response)
  end

  private

  attr_reader :runner_callback_adapter, :webhook_destination_adapter

  def response
    @response ||= runner_callback_adapter.fetch_full_submission
  end
end
