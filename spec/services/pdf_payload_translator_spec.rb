require 'rails_helper'

RSpec.describe PdfPayloadTranslator do
  let(:translator) { described_class.new(decrypted_submission) }

  describe '#to_h' do
    context 'with a valid decrypted submission' do
      let(:submission_id) { SecureRandom.uuid }
      let(:decrypted_submission) do
        JSON.parse(
          File.read(
            Rails.root.join('spec/fixtures/payloads/valid_submission.json')
          )
        ).merge(submission_id: submission_id)
      end
      let(:expected_payload) do
        {
          submission: JSON.parse(File.read(
                                   Rails.root.join('spec/fixtures/payloads/pdf_generator.json')
                                 )).merge('submission_id' => submission_id)
        }.deep_symbolize_keys
      end

      it 'creates the correct pdf payload' do
        expect(translator.to_h).to eq(expected_payload)
      end
    end
  end
end
