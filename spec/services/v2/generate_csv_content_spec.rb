require 'rails_helper'

RSpec.describe V2::GenerateCsvContent do
  subject(:generate_csv_content) { described_class.new(payload_service: payload_service) }

  let(:payload_service) do
    V2::SubmissionPayloadService.new(payload)
  end
  let(:submission_at) { Time.zone.now.iso8601(3) }

  let(:payload) do
    {
      'meta' => { 'submission_at' => submission_at },
      'service' => { 'id' => SecureRandom.uuid },
      'pages' => [
        {
          'heading' => 'Your name',
          'answers' => [
            {
              'field_id' => 'name_text_1',
              'answer' => 'Stormtrooper'
            },
            {
              'field_id' => 'name_text_2',
              'answer' => 'FN-some-last-name'
            }
          ]
        },
        {
          'heading' => '',
          'answers' => [
            {
              'field_id' => 'your-email-address_text_1',
              'answer' => 'fb-acceptance-tests@digital.justice.gov.uk'
            }
          ]
        }
      ]
    }
  end

  context 'when requesting a csv with a submission' do
    let(:expected_column_0) do
      %w[
        submission_id
        submission_at
        name_text_1
        name_text_2
        your-email-address_text_1
      ]
    end
    let(:expected_column_1) do
      [
        payload_service.submission_id,
        submission_at,
        'Stormtrooper',
        'FN-some-last-name',
        'fb-acceptance-tests@digital.justice.gov.uk'
      ]
    end

    it 'returns an Attachment object' do
      result = generate_csv_content.execute
      expect(result.class).to eq(Attachment)
    end

    it 'creates the correct file name and type' do
      result = generate_csv_content.execute

      expect(result.filename).to eq("#{payload_service.submission_id}-answers.csv")
      expect(result.mimetype).to eq('text/csv')
    end

    it 'adds the correct info to the attachment object' do
      result = generate_csv_content.execute
      file_contents = File.open(result.path).read
      csv = CSV.new(file_contents).read

      expect(csv[0]).to eq(expected_column_0)
      expect(csv[1]).to eq(expected_column_1)
    end
  end
end
