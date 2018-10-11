class ProcessSubmissionJob < ApplicationJob
  queue_as :default

  def perform(submission_id:)
    @submission = Submission.find(submission_id)
    @submission.update_status(:processing)

    @submission.complete
  end

  def on_retryable_exception(error)
    logger.warn "RETRYABLE EXCEPTION! @deployment #{@deployment.inspect}"
    @submission.fail!(retryable: true) if @submission
    super
  end

  def on_non_retryable_exception(error)
    @submission.fail!(retryable: false) if @submission
    super
  end

end
