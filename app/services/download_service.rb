class DownloadService
  # returns Hash
  # {"https://my.domain/some/path/file.ext"=>"/the/file/path/file.ext"}
  def self.download_in_parallel(urls:, target_dir: nil, headers: {})
    new(urls: urls, target_dir: target_dir, headers: headers).download_in_parallel
  end

  attr_reader :urls, :target_dir, :headers

  def initialize(urls:, target_dir: nil, headers: {})
    @urls = urls
    @target_dir = target_dir
    @headers = headers
  end

  def download_in_parallel
    actual_dir = target_dir || Dir.mktmpdir
    results = {}

    hydra = Typhoeus::Hydra.hydra

    urls.each do |url|
      file = file_path_for_download(url: url, target_dir: actual_dir)
      request = construct_request(url: url, file_path: file, headers: headers)
      results[url] = file
      hydra.queue(request)
    end
    hydra.run
    results
  end

  private

  def download(url:, target_dir: nil, headers: {})
    path = file_path_for_download(url: url, target_dir: target_dir)
    request = construct_request(url: url, file_path: path, headers: headers)
    request.run
    path
  end

  def now
    @now ||= Time.now.to_i
  end

  def payload
    @payload ||= { encrypted_user_id_and_token: headers['x-encrypted-user-id-and-token'], iat: now }
  end

  def jwt_payload
    @jwt_payload ||= { iat: now, checksum: Digest::SHA256.hexdigest(payload.to_json) }
  end

  def query_string_payload
    @query_string_payload ||= Base64.urlsafe_encode64(payload.to_json, padding: false)
  end

  def request_headers
    @request_headers ||= { 'x-access-token' => JWT.encode(jwt_payload, 'service-token', 'HS256') }
  end

  def request_url_from_url(url)
    uri = URI.parse(url)
    URI::Generic.build(scheme: uri.scheme, host: uri.host, port: uri.port, path: uri.path, query: "payload=#{query_string_payload}").to_s
  end

  def construct_request(url:, file_path:, headers: {})
    request = Typhoeus::Request.new(request_url_from_url(url), followlocation: true, headers: request_headers)
    request.on_headers do |response|
      if response.code != 200
        raise "Request failed (#{response.code}: #{response.return_code} #{request.url})"
      end
    end
    open_file = File.open(file_path, 'wb')
    # writing a chunk at a time is way more efficient for large files
    # as Typhoeus won't then try to hold the whole body in RAM
    request.on_body do |chunk|
      open_file.write(chunk)
    end
    request.on_complete do |response|
      open_file.close
      if response.code != 200
        raise "Request failed (#{response.code}: #{response.return_code} #{request.url})"
      end
      # Note that response.body is "", cause it's been cleared as we go
    end
    request
  end

  def file_path_for_download(url:, target_dir: nil)
    actual_dir = target_dir || Dir.mktmpdir
    filename = File.basename(URI.parse(url).path)
    File.join(actual_dir, filename)
  end
end
