module Filters
  class ValidateEncryptedSubmission
    def self.before(controller)
      if controller.submission_params[:encrypted_submission].blank?
        controller.render json: {
          message: ['Encrypted Submission is missing']
        }, status: :unprocessable_entity
      else
        begin
          controller.decrypted_submission
        rescue StandardError => e
          controller.render json: {
            message: ['Unable to decrypt submission payload']
          }, status: :unprocessable_entity
        end
      end
    end
  end
end
