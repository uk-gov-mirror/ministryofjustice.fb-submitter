module Adapters
  class RunnerCallback

    class FrontendRequestError < StandardError
    end

    def fetch_full_submission
      url = "www.example.com"
      responce = Typhoeus::Request.new(
          url,
          method: :get,
          # body: "this is a request body",
          # params: { field1: "a field" },
          # headers: { Accept: "text/html" }
      ).run
      unless responce.success?
        raise FrontendRequestError, "request for  #{url} returned response status of: #{responce.code}"
      end
      JSON.parse(responce.body).symbolize_keys
    end
  end
end
