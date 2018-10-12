class ProcessSubmissionJob < ApplicationJob
  queue_as :default

  def perform(submission_id:)
    @submission = Submission.find(submission_id)
    @submission.update_status(:processing)

    url_file_map = retrieve_all_in_parallel!(@submission.unique_urls)


    @submission.complete!
  end

  def retrieve_all_in_parallel!(urls)
    
  end


  def on_retryable_exception(error)
    logger.warn "RETRYABLE EXCEPTION! @submission #{@submission.inspect}"
    @submission.fail!(retryable: true) if @submission
    super
  end

  def on_non_retryable_exception(error)
    @submission.fail!(retryable: false) if @submission
    super
  end

end
