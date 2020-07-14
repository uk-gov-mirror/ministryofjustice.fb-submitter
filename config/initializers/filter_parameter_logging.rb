# Be sure to restart your server when you modify this file.

# Configure sensitive parameters which will be filtered from the log file.
#
Rails.application.config.filter_parameters += [
  :actions,
  :submission,
  :attachments,
  :password,
  :encrypted_user_id_and_token,
  :to,
  :subject
]
