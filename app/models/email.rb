class Email
  include ActiveModel::Model

  attr_accessor :to, :subject, :body, :template_name, :extra_personalisation

  validates :template_name, inclusion: { in: TemplateMappingService::Email::ALL }
  validates :to, format: { with: /.+@.+\..+/ }

  def extra_personalisation
    @extra_personalisation || {}
  end

  def template_id
    TemplateMappingService::Email.template_id_for_name(template_name)
  end

  def personalisation
    hash = {
      subject: subject,
      body: body
    }

    hash.reverse_merge!(extra_personalisation)

    hash
  end
end
