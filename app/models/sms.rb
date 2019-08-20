class Sms
  include ActiveModel::Model

  attr_accessor :to, :body, :template_name, :extra_personalisation

  validates :template_name, inclusion: { in: TemplateMappingService::Sms::ALL }
  validates :to, format: { with: /\A\+{0,1}\d{9,16}\z/ }

  def extra_personalisation
    @extra_personalisation || {}
  end

  def template_id
    TemplateMappingService::Sms.template_id_for_name(template_name)
  end

  def personalisation
    hash = {
      body: body
    }

    hash.reverse_merge!(extra_personalisation)

    hash
  end
end
