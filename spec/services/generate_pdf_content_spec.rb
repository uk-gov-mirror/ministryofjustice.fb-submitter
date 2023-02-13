require_relative '../../app/services/generate_pdf_content'

describe GeneratePdfContent do
  subject(:pdf_service) { described_class.new(pdf_api_gateway: gateway, payload:) }

  let(:gateway) { instance_spy('Adapters::PdfApi', generate_pdf: 'some pdf contents') }
  let(:submission_id) { 'some-submission-id' }
  let(:pdf_data) { { some: 'payload', submission_id: } }
  let(:payload) { { submission: pdf_data } }

  context 'when requesting a pdf with a submission' do
    it 'calls generate_pdf on the gateway' do
      pdf_service.execute
      expect(gateway).to have_received(:generate_pdf).with(submission: pdf_data)
    end

    it 'returns an Attachment object' do
      result = pdf_service.execute
      expect(result.class).to eq(Attachment)
    end

    it 'assigns the correct info the the Attachment object' do
      result = pdf_service.execute
      expect(result.mimetype).to eq('application/pdf')
      expect(File.open(result.path).read).to eq('some pdf contents')
    end

    context 'when there is no reference number present' do
      it 'uses the submission id in the file name' do
        result = pdf_service.execute
        expect(result.filename).to eq("#{submission_id}-answers.pdf")
      end
    end

    context 'when there is a reference number present' do
      let(:reference_number) { 'some-reference-number' }
      let(:pdf_data) do
        { some: 'payload', submission_id:, reference_number: }
      end

      it 'uses the reference number in the file name' do
        result = pdf_service.execute
        expect(result.filename).to eq("#{reference_number}-answers.pdf")
      end
    end
  end
end
