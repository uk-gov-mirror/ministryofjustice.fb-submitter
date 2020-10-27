module Adapters
  class PdfApi
    class ClientRequestError < StandardError
    end

    def initialize(root_url:, token:)
      @root_url = root_url
      @token = token
    end

    def generate_pdf(submission:)
      url = URI.join(root_url, '/v1/pdfs')
      response = Typhoeus.post(url, body: submission.to_json, headers: headers)

      raise ClientRequestError, "request for #{url} returned response status of: #{response.code}" unless response.success?

      response.body
    end

    private

    def headers
      {
        'x-access-token-v2' => token,
        'Accept' => 'application/json',
        'Content-Type' => 'application/json'
      }
    end

    attr_reader :root_url, :token
  end
end
