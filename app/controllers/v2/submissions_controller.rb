module V2
  class SubmissionsController < ActionController::API
    include Concerns::ContentNegotiation
    include Concerns::V2ErrorHandling
    before_action ::Filters::AuthenticateApplication

    def create
      decrypted_submission = SubmissionEncryption.new.decrypt(
        submission_params[:encrypted_submission]
      )

      @submission = Submission.create!(
        payload: SubmissionEncryption.new.encrypt(decrypted_submission),
        access_token: access_token
      )

      V2::ProcessSubmissionJob.perform_later(
        submission_id: @submission.id
      )

      render json: {}, status: :created
    end

    def submission_params
      params.permit(:encrypted_submission)
    end

    def access_token
      request.authorization.to_s.gsub(/^Bearer /, '')
    end
  end
end
