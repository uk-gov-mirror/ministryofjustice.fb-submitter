require 'rails_helper'

RSpec.describe PdfPayloadTranslator do
  let(:translator) { described_class.new(decrypted_submission) }

  describe '#to_h' do
    context 'with a valid decrypted submission' do
      let(:submission_id) { SecureRandom.uuid }
      let(:valid_submission) do
        JSON.parse(File.read(Rails.root.join('spec/fixtures/payloads/valid_submission.json')))
      end
      let(:pdf_fixture) do
        JSON.parse(File.read(Rails.root.join('spec/fixtures/payloads/pdf_generator.json')))
      end

      context 'when there is no reference number present' do
        let(:decrypted_submission) do
          valid_submission.merge(submission_id:)
        end
        let(:expected_payload) do
          {
            submission: pdf_fixture.merge('submission_id' => submission_id)
          }.deep_symbolize_keys
        end

        it 'creates the correct pdf payload' do
          expect(translator.to_h).to eq(expected_payload)
        end
      end

      context 'when there is a reference number present' do
        let(:reference_number) { 'some-reference-number' }
        let(:decrypted_submission) do
          sub = valid_submission.merge(submission_id:)
          sub['meta']['reference_number'] = reference_number
          sub
        end
        let(:expected_payload) do
          {
            submission: pdf_fixture.merge(
              {
                'submission_id' => submission_id,
                'reference_number' => reference_number
              }
            )
          }.deep_symbolize_keys
        end

        it 'creates the correct pdf payload' do
          expect(translator.to_h).to eq(expected_payload)
        end
      end
    end
  end
end
