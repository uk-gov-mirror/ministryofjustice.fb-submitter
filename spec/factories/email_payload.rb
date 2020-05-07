FactoryBot.define do
  factory :email_payload do
    submission_id { SecureRandom.uuid }
    attachments { [] }
    succeeded_at {}
  end
end
