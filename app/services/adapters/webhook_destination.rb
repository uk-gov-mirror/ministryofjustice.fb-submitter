module Adapters
  class WebhookDestination

    class DestinationRequestError < StandardError
    end

    def initialize(url:)
      @url = url
    end

    def send_webhook(body:)
      response = Typhoeus::Request.new(
          url,
          method: :post,
          body: body
      ).run
      unless response.success?
        raise DestinationRequestError, "request for #{url} returned response status of: #{response.code}"
      end
    end

    private

    attr_reader :url
  end
end
