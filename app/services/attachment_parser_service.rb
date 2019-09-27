class AttachmentParserService

  def initialize(attachments_array:)
      @attachments_array = attachments_array
  end

  def execute
    attachments_array.map do |attachment|
      Attachment.new(
        url: attachment.fetch(:url),
        mimetype: attachment.fetch(:mimetype),
        filename: attachment.fetch(:filename),
        type: attachment.fetch(:type),
        path: nil
      )
    end
  end

  private

  attr_reader :attachments_array
end
