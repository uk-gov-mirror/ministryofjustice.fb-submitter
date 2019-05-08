require 'notifications/client'

class SaveReturnEmailMagicLinkJob < ApplicationJob
  queue_as :default

  def perform(email:, magic_link:)
    response = client.send_email(
      email_address: email,
      template_id: template_id,
      personalisation: {
        magic_link: magic_link
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
    ENV['NOTIFY_SAVE_RETURN_EMAIL_MAGIC_LINK_TEMPLATE_ID']
  end
end
