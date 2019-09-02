class JsonWebhookService

  def initialize(runner_callback_adaptor:, webhook_destnation_adaptor:)
    @runner_callback_adaptor = runner_callback_adaptor
    @webhook_destnation_adaptor = webhook_destnation_adaptor
  end

  def execute()
    runner_callback_adaptor.fetch_full_submission(url: 'example.com')
    webhook_destnation_adaptor.send_post(url: 'example.com', body: {})
  end

  private
  attr_reader :runner_callback_adaptor, :webhook_destnation_adaptor
end
