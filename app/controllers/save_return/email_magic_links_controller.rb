module SaveReturn
  class EmailMagicLinksController < ApplicationController
    def create
      if job_class.perform_later(email: params[:email],
                                 magic_link: params[:magic_link],
                                 template_context: template_context)
        head :created
      end
    end

    private

    def template_context
      (params[:template_context] || ActionController::Parameters.new).to_unsafe_hash
    end

    def job_class
      SaveReturnEmailMagicLinkJob
    end
  end
end
