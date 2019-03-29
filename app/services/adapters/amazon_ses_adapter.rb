module Adapters
  class AmazonSESAdapter
    # creds automatically retrieved from
    # ENV['AWS_ACCESS_KEY_ID'] and ENV['AWS_SECRET_ACCESS_KEY']
    def self.send_mail( opts = {} )
      Rails.logger.debug "send_mail to #{opts[:to]}"
      Rails.logger.debug "raw_message: #{opts[:raw_message]}"
      Rails.logger.debug "send_mail from #{opts[:from]}"

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
