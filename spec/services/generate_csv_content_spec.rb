require 'rails_helper'

require_relative '../../app/services/generate_csv_content'
require_relative '../../app/services/submission_payload_service'

describe GenerateCsvContent do
  subject { described_class.new(payload_service:) }

  let(:payload_service) do
    SubmissionPayloadService.new(payload)
  end

  let(:payload) do
    create(:submission, :csv).decrypted_payload
  end

  # rubocop:disable RSpec/ExampleLength
  context 'when requesting a csv with a submission' do
    it 'returns an Attachment object' do
      result = subject.execute
      expect(result.class).to eq(Attachment)
    end

    it 'assigns the correct info the Attachment object' do
      result = subject.execute

      expect(result.filename).to eq("#{payload_service.submission_id}-answers.csv")
      expect(result.mimetype).to eq('text/csv')

      file_contents = File.open(result.path).read
      csv = CSV.new(file_contents).read

      expect(csv[0]).to eql(%w[
        submission_id
        submission_at
        first_name
        last_name
        has-email
        email_address
        complaint_details
        checkbox-apples
        checkbox-pears
        date
        number_cats
        cat_spy
        cat_breed
        upload
      ])

      expect(csv[1]).to eql([payload_service.submission_id,
                             '2019-12-18T09:25:59.238Z',
                             'Bob',
                             'Smith',
                             'yes',
                             'bob.smith@digital.justice.gov.uk',
                             'Foo bar baz',
                             'yes',
                             'yes',
                             '2007-11-12',
                             '28',
                             'machine answer 3',
                             'California Spangled',
                             'data not available in CSV format'])
    end
  end
  # rubocop:enable RSpec/ExampleLength
end
