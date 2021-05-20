class Metrics
  attr_reader :object, :client, :logger

  def initialize(object, client = MixpanelClient.new, logger = Rails.logger)
    @object = object
    @client = client
    @logger = logger
  end

  def track(event_name, properties)
    return unless client.can_track?

    client.track(object.id, event_name, properties)
    logger.info("Tracking event: '#{event_name}': #{properties}")
  rescue StandardError => e
    Sentry.capture_exception(e)
  end
end
