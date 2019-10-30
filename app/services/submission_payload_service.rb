require 'active_support/core_ext/hash'

class SubmissionPayloadService
  attr_reader :attachments, :actions, :submission

  def initialize(payload)
    payload = payload.with_indifferent_access
    @attachments = payload.fetch(:attachments)
    @actions = payload.fetch(:actions)
    @submission = payload.fetch(:submission)
  end

  def user_answers_map
    questions = {}
    submission.fetch('sections', []).each do |section|
      section.fetch('questions').each do |question|
        questions[question.fetch('key')] = question.fetch('answer')
      end
    end
    questions
  end
end
