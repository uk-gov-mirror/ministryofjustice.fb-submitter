module V2
  class ReplayBatchSubmission
    attr_accessor :date_from, :date_to, :service_slug, :new_destination_email

    ALLOWED_DOMAINS = [
      'justice.gov.uk',
      'digital.justice.gov.uk',
      'cica.gov.uk',
      'ccrc.gov.uk',
      'judicialappointments.gov.uk',
      'judicialombudsman.gov.uk',
      'ospt.gov.uk',
      'gov.sscl.com',
      'hmcts.net'
    ].freeze

    TWENTY_EIGHT_DAYS_IN_SECONDS = 28*24*60*60

    def initialize(date_from:, date_to:, service_slug:, new_destination_email:)
      @date_from = DateTime.parse(date_from)
      @date_to = DateTime.parse(date_to)
      @service_slug = service_slug
      @new_destination_email = new_destination_email
    end

    def call
      return unless validate_dates
      return unless validate_destination

      process_submissions
    end

    def validate_dates
      date_from < date_to
    end

    def validate_destination
      new_destination_email.split('@').last.downcase.in?(ALLOWED_DOMAINS)
    end

    def process_submissions
    end

    def get_submissions_to_process
      Submission.where(created_at: date_from..date_to, service_slug:)
    end

    private


  end
end