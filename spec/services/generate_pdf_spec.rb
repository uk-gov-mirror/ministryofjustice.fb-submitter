require_relative '../../app/services/generate_pdf'

describe GeneratePdf do
  subject(:pdf_service) { described_class.new(pdf_generator_gateway: gateway) }

  let(:gateway) { instance_double('Adapters::PdfGenerator', generate_pdf: 'some pdf contents') }
  let(:payload) { { some: 'payload' } }

  context 'when requesting a pdf with a submission' do
    it 'calls generate_pdf on the gateway' do
      pdf_service.execute(payload)
      expect(gateway).to have_received(:generate_pdf).with(submission: payload)
    end

    it 'returns the result of the API call' do
      result = pdf_service.execute(payload)
      expect(result).to eq('some pdf contents')
    end
  end
end
