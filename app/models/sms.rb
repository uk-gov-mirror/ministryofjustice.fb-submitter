class Sms
  include ActiveModel::Model

  attr_accessor :to, :body, :template_name

  validates :template_name, inclusion: { in: TemplateMappingService::Sms::ALL }

  def template_id
    TemplateMappingService::Sms.template_id_for_name(template_name)
  end

  def personalisation
    {
      body: body
    }
  end
end
