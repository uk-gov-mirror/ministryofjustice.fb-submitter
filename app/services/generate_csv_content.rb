require 'csv'
require 'tempfile'
require_relative '../value_objects/attachment'

class GenerateCsvContent
  def initialize(payload:)
    @payload = payload
  end

  def execute
    tmp_csv = generate_temp_file
    generate_attachment_object(tmp_csv)
  end

  private

  def csv_contents
    return @csv_contents if @csv_contents

    @csv_contents = []
    @csv_contents << csv_headers
    @csv_contents << csv_data
  end

  def csv_data
    data = []
    data << payload[:submission][:serviceSlug]
    data << payload[:submission][:submission_id]
    data.concat(payload[:submission][:submissionAnswers].values)
    data
  end

  def csv_headers
    fixed_headers = ['slug', 'submission_id']
    dynamic_headers = payload[:submission][:submissionAnswers].keys

    fixed_headers + dynamic_headers
  end

  def generate_temp_file
    tmp_csv = Tempfile.new

    CSV.open(tmp_csv.path, 'w') do |csv|
      csv_contents.each do |row|
        csv << row
      end
    end

    tmp_csv.rewind
    tmp_csv
  end

  def generate_attachment_object(tmp_csv)
    attachment = Attachment.new(
      filename: "#{payload[:submission][:submission_id]}-answers.csv",
      mimetype: 'text/csv'
    )
    attachment.file = tmp_csv
    attachment
  end

  attr_reader :payload
end
