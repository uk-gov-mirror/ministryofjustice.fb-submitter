class JsonWebhookService
  def initialize(runner_callback_adapter:, webhook_destination_adapter:)
    @runner_callback_adapter = runner_callback_adapter
    @webhook_destination_adapter = webhook_destination_adapter
  end

  def execute()
    res = runner_callback_adapter.fetch_full_submission
    webhook_destination_adapter.send_webhook(body: res)
  end

  private

  attr_reader :runner_callback_adapter, :webhook_destination_adapter
end
