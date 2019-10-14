require 'rails_helper'

RSpec.describe SaveTempPdf do
  subject(:pdf_attachments_service) do
    described_class.new(
      generate_pdf_content_service: generate_pdf_content_service,
      tmp_file_gateway: Tempfile
    )
  end

  let(:generate_pdf_content_service) do
    instance_double('GeneratePdf', execute: 'some pdf contents')
  end

  let(:result) { pdf_attachments_service.execute(file_name: '123') }

  it 'returns the temporary file locations of the downloaded pdfs' do
    expect(result).to match(%r{/tmp\/123(.*).pdf})
  end

  it 'writes the contents of the PDF to the temporary file' do
    expect(File.read(result)).to eq('some pdf contents')
  end
end
