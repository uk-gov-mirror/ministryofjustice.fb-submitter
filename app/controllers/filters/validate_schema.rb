module Filters
  class ValidateSchema
    SUBMISSION_PAYLOAD_SCHEMA_FILE = Rails.root.join(
      'api_documentation', 'v2', 'schemas', 'submission_payload.json'
    ).freeze
    SUBMISSION_PAYLOAD_SCHEMA = JSON.parse(
      File.read(SUBMISSION_PAYLOAD_SCHEMA_FILE)
    ).freeze

    def self.before(controller)
      JSON::Validator.validate!(
        SUBMISSION_PAYLOAD_SCHEMA,
        controller.decrypted_submission
      )
    rescue StandardError => e
      controller.render json: {
        message: [e.message]
      }, status: :unprocessable_entity
    end
  end
end
