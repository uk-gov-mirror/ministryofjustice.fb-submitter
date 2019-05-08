module SaveReturn
  class EmailMagicLinksController < ApplicationController
    def create
      if SaveReturnEmailMagicLinkJob.perform_later(email: permitted_params[:email], magic_link: permitted_params[:magic_link])
        head :created
      end
    end

    private

    def permitted_params
      params.permit(:email, :magic_link)
    end
  end
end
