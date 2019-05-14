require 'notifications/client'
class SaveReturnEmailConfirmationJob < ApplicationJob
  queue_as :default

  def perform(email:, confirmation_link:, template_context: {})
    response = client.send_email(
      email_address: email,
      template_id: template_id,
      personalisation: {
        confirmation_link: confirmation_link
      }
    )
  end

  private

  def client
    @client ||= Notifications::Client.new(api_key)
  end

  def api_key
    ENV['NOTIFY_API_KEY']
  end

  def template_id
    ENV['NOTIFY_SAVE_RETURN_EMAIL_TEMPLATE_ID']
  end
end
