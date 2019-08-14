class Email
  include ActiveModel::Model

  attr_accessor :to, :subject, :body, :template_name

  validates :template_name, inclusion: { in: TemplateMappingService::Email::ALL }

  def template_id
    TemplateMappingService::Email.template_id_for_name(template_name)
  end

  def personalisation
    {
      subject: subject,
      body: body
    }
  end
end
