class GeneratePdfContent
  def initialize(pdf_api_gateway:, payload:)
    @pdf_api_gateway = pdf_api_gateway
    @payload = payload
  end

  def execute
    pdf_api_gateway.generate_pdf(
      submission: payload.fetch(:submission)
    )
  end

  private

  attr_reader :pdf_api_gateway, :payload
end
