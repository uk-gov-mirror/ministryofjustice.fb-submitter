module Adapters
  class JweWebhookDestination
    class ClientRequestError < StandardError
    end

    def initialize(url:, key:)
      @url = url
      @key = key
    end

    def send_webhook(body:)
      response = Typhoeus::Request.new(
        url,
        method: :post,
        body: encrypted_body(body)
      ).run

      p 'encrypted_body'
      p encrypted_body(body)

      p 'response headers ---'
      p response.headers

      p 'response body ---'
      p response.body

      unless response.success?
        raise ClientRequestError, "request for #{url} returned response status of: #{response.code}"
      end
    end

    private

    def body_as_string(body)
      if body.is_a?(String)
        body
      else
        body.to_json
      end
    end

    def encrypted_body(body)
      JWE.encrypt(body_as_string(body), key, alg: 'dir')
    end

    attr_reader :url, :key
  end
end
