module Adapters
  class AmazonSESAdapter
    # creds automatically retrieved from
    # ENV['AWS_ACCESS_KEY_ID'] and ENV['AWS_SECRET_ACCESS_KEY']
    def self.send_mail(opts = {})
      client.send_email(
        from_email_address: opts[:from],
        destination: {
          to_addresses: [opts[:to]]
        },
        content: {
          raw: {
            data: opts[:raw_message].to_s
          }
        }
      )
    end

    def self.client
      Aws::SESV2::Client.new(region: 'eu-west-1')
    end
  end
end
