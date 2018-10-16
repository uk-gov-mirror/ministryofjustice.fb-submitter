class DownloadService
  def self.download(url:, target_dir: nil)
    path = file_path_for_download(url: url, target_dir: target_dir)
    request = construct_request(url: url, file_path: path)
    request.run
    path
  end

  def self.download_in_parallel(urls:, target_dir: nil)
    actual_dir = target_dir || Dir.mktmpdir
    results = {}

    hydra = Typhoeus::Hydra.hydra

    urls.each do |url|
      file = file_path_for_download(url: url, target_dir: actual_dir)
      request = construct_request(url: url, file_path: file)
      results[url] = file
      hydra.queue(request)
    end
    hydra.run
    results
  end

  def self.construct_request(url:, file_path:)
    request = Typhoeus::Request.new(url, followlocation: true)
    request.on_headers do |response|
      if response.code != 200
        raise "Request failed"
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
      # Note that response.body is "", cause it's been cleared as we go
    end
    request
  end

  def self.file_path_for_download(url:, target_dir: nil)
    actual_dir = target_dir || Dir.mktmpdir
    filename = File.basename(URI.parse(url).path)
    File.join(actual_dir, filename)
  end

end
