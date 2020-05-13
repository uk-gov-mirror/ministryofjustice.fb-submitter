FactoryBot.define do
  factory :email_payload do
    submission_id {}
    attachments { [] }
    succeeded_at {}
    to {}
  end
end
