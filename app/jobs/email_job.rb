require 'notifications/client'

class EmailJob < ApplicationJob
  queue_as :default

  def perform(message:)
    email = Email.new(message)

    response = client.send_email(
      email_address: email.to,
      template_id: email.template_id,
      personalisation: email.personalisation
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
