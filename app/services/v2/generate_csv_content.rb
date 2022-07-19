require 'csv'
require 'tempfile'

module V2
  class GenerateCsvContent
    FIXED_HEADERS = %w[submission_id submission_at].freeze
    DATA_UNAVAILABLE = 'Data not available in CSV format'.freeze

    def initialize(payload_service:)
      @payload_service = payload_service
    end

    def execute
      tmp_csv = generate_temp_file
      generate_attachment_object(tmp_csv)
    end

    private

    attr_reader :payload_service

    def generate_temp_file
      tmp_csv = Tempfile.new

      CSV.open(tmp_csv.path, 'w') do |csv|
        csv_contents.each { |row| csv << row }
      end

      tmp_csv.rewind
      tmp_csv
    end

    def csv_contents
      return @csv_contents if @csv_contents

      @csv_contents = []
      @csv_contents << csv_headers
      @csv_contents << csv_data
    end

    def answer_values
      payload_service.user_answers.values.map do |value|
        value.is_a?(Hash) || value.is_a?(Array) ? DATA_UNAVAILABLE : value
      end
    end

    def csv_data
      data = []

      data << payload_service.submission_id
      data << payload_service.submission_at.iso8601(3)
      data.concat(answer_values)

      data
    end

    def csv_headers
      FIXED_HEADERS + payload_service.user_answers.keys
    end

    def generate_attachment_object(tmp_csv)
      attachment = Attachment.new(
        filename: "#{payload_service.submission_id}-answers.csv",
        mimetype: 'text/csv'
      )
      attachment.file = tmp_csv
      attachment
    end
  end
end
