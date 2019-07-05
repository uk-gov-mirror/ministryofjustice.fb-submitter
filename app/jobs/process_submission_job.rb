class ProcessSubmissionJob < ApplicationJob
  queue_as :default

  def perform(submission_id:)
    service = ProcessSubmissionService.new(submission_id: submission_id)
    service.perform
  end
end
