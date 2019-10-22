module Adapters
  class MockAmazonSESAdapter
    def self.send_mail(opts = {})
      Typhoeus.post(ENV.fetch('EMAIL_ENDPOINT_OVERRIDE'), body: opts)
    end
  end
end
