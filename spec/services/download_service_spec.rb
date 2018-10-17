require 'rails_helper'

describe DownloadService do
  let(:url) { 'https://my.domain/some/path/file.ext' }
  let(:headers) { {'x-access-token' => 'sometoken'} }
  let(:args) { {url: url, target_dir: '/my/target/dir', headers: headers} }
  let(:mock_hydra) { double('hydra', run: 'run result', queue: 'queue result') }
  before do
    allow(Typhoeus::Hydra).to receive(:hydra).and_return(mock_hydra)
  end

  describe '#file_path_for_download' do
    describe 'return value' do
      let(:return_value) { described_class.file_path_for_download(args) }

      context 'given a target_dir' do
        let(:args) { {url: url, target_dir: '/my/target/dir'} }

        it 'is the last element of the url, in the given target_dir' do
          expect(return_value).to eq('/my/target/dir/file.ext')
        end
      end

      context 'when no target_dir is given' do
        let(:args) { {url: url} }
        before do
          allow(Dir).to receive(:mktmpdir).and_return('/a/new/temp/dir')
        end

        it 'makes a temp dir' do
          expect(Dir).to receive(:mktmpdir)
          described_class.file_path_for_download(args)
        end

        it 'is the last element of the url, in the new temp dir' do
          expect(return_value).to eq('/a/new/temp/dir/file.ext')
        end
      end
    end
  end

  describe '#construct_request' do
    let(:args) { {url: url, file_path: '/my/file/path'} }
    before do
      allow(File).to receive(:open).with('/my/file/path', 'wb').and_return(double(File))
    end
    describe 'the return value' do
      let(:return_value) { described_class.construct_request(args) }

      it 'is a Typhoeus::Request' do
        expect(return_value).to be_a(Typhoeus::Request)
      end

      it 'has the given url' do
        expect(return_value.url).to eq(url)
      end

      # difficult to test the contents of blocks!
      it 'has an on_body proc' do
        expect(return_value.on_body.first).to be_a(Proc)
      end

      it 'has an on_headers proc' do
        expect(return_value.on_headers.first).to be_a(Proc)
      end

      it 'has an on_complete proc' do
        expect(return_value.on_complete.first).to be_a(Proc)
      end
    end
  end

  describe '.download' do
    let(:path) { '/the/file/path' }
    let(:mock_request) { double('request', run: 'run result') }
    before do
      allow(described_class).to receive(:construct_request).and_return(mock_request)
      allow(described_class).to receive(:file_path_for_download).with(url: url, target_dir: '/my/target/dir').and_return(path + '/file.ext')
    end

    it 'gets the file_path_for_download with the given args' do
      expect(described_class).to receive(:file_path_for_download).with(url: url, target_dir: '/my/target/dir').and_return(path)
      described_class.download(args)
    end

    it 'constructs a request for the correct url and the file_path_for_download' do
      expect(described_class).to receive(:construct_request).with(url: url, file_path: path + '/file.ext', headers: headers).and_return(mock_request)
      described_class.download(args)
    end

    it 'runs the request' do
      expect(mock_request).to receive(:run)
      described_class.download(args)
    end

    it 'returns the path' do
      expect(described_class.download(args)).to eq(path + '/file.ext')
    end
  end


  describe '.download_in_parallel' do
    let(:path) { '/the/file/path' }
    let(:mock_request) { double('request', run: 'run result') }

    before do
      allow(described_class).to receive(:construct_request).and_return(mock_request)
      allow(described_class).to receive(:file_path_for_download).and_return(path + '/file.ext')
    end

    context 'when no target_dir is given' do
      before do
        allow(Dir).to receive(:mktmpdir).and_return('/a/new/temp/dir')
      end

      it 'makes a temp dir' do
        expect(Dir).to receive(:mktmpdir)
        described_class.download_in_parallel(urls: [url])
      end
    end

    context 'when a target_dir is given' do
      let(:target_dir) { '/my/tmp/dir' }

      it 'does not make a temp dir' do
        expect(Dir).to_not receive(:mktmpdir)
        described_class.download_in_parallel(urls: [url], target_dir: target_dir)
      end
    end

    context 'given an array of urls' do
      let(:url1) { 'https://my.domain/some/path/file.ext' }
      let(:url2) { 'https://another.domain/some/otherfile.ext' }
      let(:args) { {urls: [url1, url2], target_dir: path, headers: headers} }
      let(:mock_request_1) { double('request1') }
      let(:mock_request_2) { double('request2') }

      before do
        allow(described_class).to receive(:file_path_for_download).with(url: url1, target_dir: path).and_return('/tmp/file1')
        allow(described_class).to receive(:file_path_for_download).with(url: url2, target_dir: path).and_return('/tmp/file2')
        allow(described_class).to receive(:construct_request).with(url: url1, file_path: '/tmp/file1', headers: headers).and_return(mock_request_1)
        allow(described_class).to receive(:construct_request).with(url: url2, file_path: '/tmp/file2', headers: headers).and_return(mock_request_2)
      end

      describe 'for each url' do
        it 'gets the file_path_for_download' do
          expect(described_class).to receive(:file_path_for_download).with(url: url1, target_dir: path).and_return('/tmp/file1')
          expect(described_class).to receive(:file_path_for_download).with(url: url2, target_dir: path).and_return('/tmp/file2')
          described_class.download_in_parallel(args)
        end

        it 'constructs a request, passing the url and file path for download' do
          expect(described_class).to receive(:construct_request).with(url: url1, file_path: '/tmp/file1', headers: headers)
          expect(described_class).to receive(:construct_request).with(url: url2, file_path: '/tmp/file2', headers: headers)
          described_class.download_in_parallel(args)
        end

        it 'queues the request' do
          expect(mock_hydra).to receive(:queue).with(mock_request_1)
          expect(mock_hydra).to receive(:queue).with(mock_request_2)
          described_class.download_in_parallel(args)
        end
      end

      it 'runs the request batch' do
        expect(mock_hydra).to receive(:run)
        described_class.download_in_parallel(args)
      end

      it 'returns the urls mapped to file paths' do
        expect( described_class.download_in_parallel(args) ).to eq({
          url1 => '/tmp/file1',
          url2 => '/tmp/file2'
        })
      end
    end
  end
end
