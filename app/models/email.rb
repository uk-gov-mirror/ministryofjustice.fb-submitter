class Email
  include ActiveModel::Model

  attr_accessor :to, :subject, :body, :template_name

  def template_id
    TemplateMappingService::Email.template_id_for_name(template_name)
  end
end
