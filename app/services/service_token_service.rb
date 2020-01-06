class ServiceTokenService
  attr_reader :service_slug

  def initialize(service_slug:)
    @service_slug = service_slug
  end

  def get
    client.get(service_slug)
  end

  def public_key
    client.public_key_for(service_slug)
  end

  private

  def client
    @client ||= Adapters::ServiceTokenCacheClient.new
  end
end
