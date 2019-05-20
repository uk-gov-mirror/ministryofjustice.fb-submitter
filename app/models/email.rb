class Email
  include ActiveModel::Model

  attr_accessor :to, :subject, :body
end
