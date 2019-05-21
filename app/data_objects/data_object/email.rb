module DataObject
  class Email
    include ActiveModel::Model

    attr_accessor :to, :subject, :body, :template_name

    validates :template_name, inclusion: { in: TemplateMappingService::Email::ALL }
  end
end
