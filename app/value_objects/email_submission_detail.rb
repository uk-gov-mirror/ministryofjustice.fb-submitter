class EmailSubmissionDetail
  include ActiveModel

  attr_accessor :from, :to, :subject, :attachments, :submission, :email_body

  def initialize(params = {})
    symbol_params = params.symbolize_keys!
    @submission   = symbol_params[:submission]
    @attachments  = symbol_params[:attachments]
    @email_body   = symbol_params[:email_body]
    @from         = symbol_params[:from]
    @subject      = symbol_params[:subject]
    @to           = symbol_params[:to]

    make_urls_absolute!
  end

  def make_urls_absolute!
    attachments.each do |attachment|
      attachment['url'] = url_resolver.ensure_absolute_url(attachment['url']) if attachment['type'] == 'output' && !attachment['url'].nil?
    end
  end

  def url_resolver(submission: @submission, environment_slug: ENV['FB_ENVIRONMENT_SLUG'])
    @url_resolver ||= Adapters::ServiceUrlResolver.new(
      service_slug: submission.service_slug,
      environment_slug: environment_slug
    )
  end
end
