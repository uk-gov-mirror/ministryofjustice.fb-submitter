require 'notifications/client'

class SaveReturnEmailProgressSavedJob < ApplicationJob
  queue_as :default

  def perform(email:)
    email = Email.new(email)

    response = client.send_email(
      email_address: email.to,
      template_id: template_id,
      personalisation: {
        subject: email.subject,
        body: email.body
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
    ENV['NOTIFY_SAVE_RETURN_EMAIL_PROGRESS_SAVED_TEMPLATE_ID']
  end
end
