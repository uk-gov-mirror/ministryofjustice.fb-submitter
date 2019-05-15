module SaveReturn
  class EmailConfirmationsController < ApplicationController
    def create
      if job_class.perform_later(email: params[:email],
                                 confirmation_link: params[:confirmation_link],
                                 template_context: template_context)
        head :created
      end
    end

    private

    def template_context
      (params[:template_context] || ActionController::Parameters.new).to_unsafe_hash
    end

    def job_class
      SaveReturnEmailConfirmationJob
    end
  end
end
