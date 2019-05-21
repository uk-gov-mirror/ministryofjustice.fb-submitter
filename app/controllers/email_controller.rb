class EmailController < ApplicationController
  # example json payload:
  #
  # {
  #   email: {
  #     to: 'user@example.com',
  #     subject: 'subject goes here',
  #     body: 'body as string goes here',
  #     template_name: 'name-of-template'
  #   }
  # }
  #
  def create
    return render_errors unless email_validator.valid?

    if job_class.perform_later(email: email_params)
      return render json: {}, status: :created
    end
  end

  private

  def email_validator
    DataObject::Email.new(email_params)
  end

  def render_errors
    render json: { name: 'bad-request.invalid-parameters' }, status: :bad_request
  end

  def email_params
    params.require(:email).permit(:to, :subject, :body, :template_name)
  end

  def job_class
    EmailJob
  end
end
