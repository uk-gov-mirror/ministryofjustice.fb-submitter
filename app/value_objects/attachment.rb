# rubocop:disable Metrics/ParameterLists
class Attachment
  attr_reader :type, :filename, :url, :mimetype, :path

  def initialize(type:, filename:, url:, mimetype:, path:, pdf_data: {})
    @type = type
    @filename = filename
    @url = url
    @mimetype = mimetype
    @path = path
    @pdf_data = pdf_data
  end

  def filename_with_extension
    head, *tail = filename.split('.').reverse
    raw_filename = tail.reverse.join.presence || head
    ext = MIME::Types[@mimetype][0].preferred_extension

    "#{raw_filename}.#{ext}"
  end
end
# rubocop:enable Metrics/ParameterLists
