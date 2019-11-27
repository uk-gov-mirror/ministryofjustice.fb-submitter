module Adapters
  class PdfApi
    class ClientRequestError < StandardError
    end

    def initialize(root_url:)
      @root_url = root_url
    end

    def generate_pdf(submission:)
      url = URI.join(root_url, '/v1/pdfs')
      response = Typhoeus.post(url, body: submission.to_json)

      raise ClientRequestError, "request for #{url} returned response status of: #{response.code}" unless response.success?

      response.body
    end

    private
    attr_reader :root_url
  end
end
