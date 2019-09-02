class JsonWebhookService

  def initialize(runner_callback_adaptor:, webhook_destination_adaptor:)
    @runner_callback_adaptor = runner_callback_adaptor
    @webhook_destination_adaptor = webhook_destination_adaptor
  end

  def execute()
    res = runner_callback_adaptor.fetch_full_submission
    webhook_destination_adaptor.send_webhook(body: res)
  end

  private
  attr_reader :runner_callback_adaptor, :webhook_destination_adaptor
end
