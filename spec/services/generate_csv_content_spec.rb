require 'rails_helper'

require_relative '../../app/services/generate_csv_content'
require_relative '../../app/services/submission_payload_service'

describe GenerateCsvContent do
  subject { described_class.new(payload_service: payload_service) }

  let(:payload_service) do
    SubmissionPayloadService.new(payload)
  end

  let(:payload) do
    create(:submission).decrypted_payload
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

      expect(csv[0]).to eql([
        'submission_id',
        'usn',
        'maat[1]',
        'fullname',
        'dob',
        'solicitor_fullname',
        'firm',
        'solicitor_email',
        'lapan',
        'offence[1].type',
        'offence[1].date',
        'offence[1].reasons',
        'documentation'
      ])

      expect(csv[1]).to eql(['1234567',
                             '6123456',
                             'john doe',
                             '1 January 1990',
                             'Mr Solicitor',
                             'Pearson',
                             'info@solicitor.co.uk',
                             '1A234B',
                             'Grand theft auto',
                             '1 January 1990',
                             'A genuine reason',
                             'an-image.jpg'])
    end
  end
  # rubocop:enable RSpec/ExampleLength
end
