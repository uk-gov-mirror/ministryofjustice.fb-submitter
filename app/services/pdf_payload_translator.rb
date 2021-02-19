class PdfPayloadTranslator
  attr_reader :decrypted_submission

  def initialize(decrypted_submission)
    @decrypted_submission = ActiveSupport::HashWithIndifferentAccess.new(
      decrypted_submission
    )
  end

  def to_h
    {
      submission: {
        submission_id: decrypted_submission[:submission_id],
        pdf_heading: meta[:pdf_heading],
        pdf_subheading: meta[:pdf_subheading],
        sections: decrypted_submission[:user_answers].map do |user_answer|
          {
            heading: '',
            summary_heading: '',
            questions: [{
              label: user_answer[:field_name],
              human_value: user_answer[:answer].is_a?(Array) ? user_answer[:answer].join("\n") : user_answer[:answer]
            }]
          }
        end
      }
    }
  end

  private

  def meta
    decrypted_submission[:meta]
  end

  def service
    decrypted_submission[:service]
  end
end
