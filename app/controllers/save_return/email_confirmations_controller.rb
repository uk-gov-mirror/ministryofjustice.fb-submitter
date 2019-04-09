module SaveReturn
  class EmailConfirmationsController < ApplicationController
    def create
      if SaveReturnEmailConfirmationJob.perform_later(email: permitted_params[:email], confirmation_link: permitted_params[:confirmation_link])
        head :created
      end
    end

    private

    def permitted_params
      params.permit(:email, :confirmation_link)
    end
  end
end
