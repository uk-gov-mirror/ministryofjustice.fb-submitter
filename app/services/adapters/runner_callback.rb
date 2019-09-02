module Adapters
  class RunnerCallback

    class FrontendRequestError < StandardError
    end

    def initialize(url:)
      @url = url
    end

    def fetch_full_submission
      response = Typhoeus::Request.new(
          url,
          method: :get,
          # body: "this is a request body",
          # headers: { Accept: "text/html" }
      ).run
      unless response.success?
        raise FrontendRequestError, "request for  #{url} returned response status of: #{response.code}"
      end
      response.body
    end

    private
    attr_reader :url
  end
end
