require 'notifications/client'

class SmsJob < ApplicationJob
  queue_as :default

  def perform(message:)
    sms = Sms.new(message)

    response = client.send_sms(
      phone_number: sms.to,
      template_id: sms.template_id,
      personalisation: sms.personalisation
    )
  end

  private

  def client
    @client ||= Notifications::Client.new(api_key)
  end

  def api_key
    ENV['NOTIFY_API_KEY']
  end
end
