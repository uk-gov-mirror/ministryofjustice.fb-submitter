module SaveReturn
  class EmailProgressSavedController < ApplicationController
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
      if job_class.perform_later(email: email_params)
        return render json: {}, status: :created
      end
    end

    private

    def email_params
      params.require(:email).permit(:to, :subject, :body, :template_name)
    end

    def job_class
      SaveReturnEmailProgressSavedJob
    end
  end
end
