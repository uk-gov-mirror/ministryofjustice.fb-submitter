class EmailSubmissionDetail
  include ActiveModel

  attr_accessor :from, :to, :subject, :body_parts, :attachments

  def initialize( params = {} )
    symbol_params = params.symbolize_keys!
    @attachments  = symbol_params[:attachments]
    @body_parts   = symbol_params[:body_parts]
    @from         = symbol_params[:from]
    @subject      = symbol_params[:subject]
    @to           = symbol_params[:to]
  end

end
