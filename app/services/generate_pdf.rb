class GeneratePdf
  def initialize(pdf_generator_gateway:)
    @pdf_generator_gateway = pdf_generator_gateway
  end

  def execute(payload)
    pdf_generator_gateway.generate_pdf(
      submission: payload.fetch(:submission)
    )
  end

  private

  attr_reader :pdf_generator_gateway
end
