require 'active_support/core_ext/hash'

class SubmissionPayloadService
  attr_reader :attachments, :actions, :submission, :submission_id, :payload

  def initialize(payload)
    @payload = payload.with_indifferent_access
    @attachments = @payload.fetch(:attachments)
    @actions = @payload.fetch(:actions)
    @submission = @payload.fetch(:submission)
    @submission_id = @payload.fetch(:submission).fetch('submission_id')
  end

  def user_answers_map
    questions = {}
    submission.fetch('sections', []).each do |section|
      section.fetch('questions').each do |question|
        questions[question.fetch('key')] = question.fetch('answer', nil)
      end
    end
    questions
  end

  # return array representing as row in a csv
  def csv_row
    row = user_answers_map.values

    row.map do |cell|
      if cell.is_a?(Hash) || cell.is_a?(Array)
        'data not available in csv format'
      else
        cell
      end
    end
  end
end
