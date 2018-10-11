class SubmissionController < ApplicationController
  def create
    @submission = Submission.new(
      submission_params(params).merge(status: Submission::STATUS[:queued])
    )
    @submission.save!
    ProcessSubmissionJob.perform_later(submission_id: @submission.id)
    render status: :created, json: @submission
  end

  private

  def submission_params(opts=params)
    opts.permit(
      :encrypted_user_id_and_token,
      :service_slug,
      :submission_details,
      :submission_type,
    )
  end
end
