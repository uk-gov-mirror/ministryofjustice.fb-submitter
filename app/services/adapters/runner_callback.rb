module Adapters
  class RunnerCallback

    class ClientRequestError < StandardError
    end

    def initialize(url:)
      @url = url
    end

    def fetch_full_submission
      response = Typhoeus::Request.new(
          url,
          method: :get,
      ).run
      unless response.success?
        raise ClientRequestError, "request for #{url} returned response status of: #{response.code}"
      end
      response.body
    end

    private

    attr_reader :url
  end
end
