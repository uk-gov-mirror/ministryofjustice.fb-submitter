class SubmissionController < ApplicationController
  def create
    @submission = Submission.create!(
      submission_params.merge(
        payload: EncryptionService.new.encrypt(payload),
        access_token: access_token
      )
    )

    Delayed::Job.enqueue(
      ProcessSubmissionService.new(submission_id: @submission.id),
      run_at: 3.seconds.from_now
    )

    render json: {}, status: :created
  end

  private

  def submission_params
    params.slice(
      :service_slug,
      :encrypted_user_id_and_token
    ).permit!
  end

  def access_token
    request.headers['x-access-token-v2']
  end

  def payload
    params.slice(
      :meta,
      :actions,
      :submission,
      :attachments
    ).permit!
  end
end
