module Adapters
  class AmazonSESAdapter
    # creds automatically retrieved from
    # ENV['AWS_ACCESS_KEY_ID'] and ENV['AWS_SECRET_ACCESS_KEY']
    def self.send_mail( opts = {} )
      client.send_raw_email({
        destinations: [ opts[:to] ],
        raw_message: {
          data: opts[:raw_message].to_s
        },
        source: opts[:from]
      })
    end

    private

    def self.client
      Aws::SES::Client.new
    end
  end
end
