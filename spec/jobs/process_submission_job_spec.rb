require 'rails_helper'

describe ProcessSubmissionJob do
  let(:mock_downloaded_files) { {'url1' => 'file1', 'url2' => 'file2'} }
  let(:downloaded_body_parts) { mock_downloaded_files }
  let(:body_part_content) do
    {
      'text/plain' => 'some plain text',
      'text/html' => '<html>some html</html>'
    }
  end
  let(:token) { 'some token' }
  let(:headers) { {'x-encrypted-user-id-and-token' => token} }
  let(:url_resolver) { double('url_resolver', ensure_absolute_urls: ['abs url1', 'abs url2'])}
  before do
    allow(Adapters::ServiceUrlResolver).to receive(:new).and_return(url_resolver)
  end

  describe '#perform' do
    let(:submission_detail) do
      {
        'from' => 'some.one@example.com',
        'to' => 'destination@example.com',
        'subject' => 'mail subject',
        'type' => 'email',
        "body_parts" => {
          "text/html"=>"https://tools.ietf.org/html/rfc2324",
          "text/plain"=>"https://tools.ietf.org/rfc/rfc2324.txt"
        },
        "attachments"=>["https://tools.ietf.org/pdf/rfc2324"]
      }
    end
    let(:submission) do
      Submission.create!(
        encrypted_user_id_and_token: token,
        status: 'queued',
        submission_details: [submission_detail]
      )
    end
    let(:detail_objects) do
      [EmailSubmissionDetail.new(submission_detail)]
    end
    let(:urls) { ['url1', 'url2'] }
    let(:mock_send_response){ {'key' => 'send response'} }
    before do
      allow(submission).to receive(:detail_objects).and_return(detail_objects)
      allow(EmailService).to receive(:send_mail).and_return( mock_send_response )
      allow(DownloadService).to receive(:download_in_parallel).and_return(
        mock_downloaded_files
      )
      allow(subject).to receive(:retrieve_mail_body_parts).and_return(body_part_content)
    end

    context 'given a valid submission_id' do
      let(:submission_id) { submission.id }
      before do
        allow(Submission).to receive(:find).with(submission_id).and_return(submission)
      end

      it 'loads the Submission' do
        expect(Submission).to receive(:find).with(submission_id).and_return(submission)
        subject.perform(submission_id: submission_id)
      end

      it 'updates the Submission status to :processing' do
        expect(submission).to receive(:update_status).with(:processing)
        subject.perform(submission_id: submission_id)
      end

      it 'gets the unique_attachment_urls' do
        expect(subject).to receive(:unique_attachment_urls).and_return(urls)
        subject.perform(submission_id: submission_id)
      end

      it 'resolves the unique_attachment_urls' do
        expect(url_resolver).to receive(:ensure_absolute_urls).with(['https://tools.ietf.org/pdf/rfc2324']).and_return(['abs url1'])
        subject.perform(submission_id: submission_id)
      end


      it 'downloads the resolved unique_attachment_urls in parallel' do
        expect(DownloadService).to receive(:download_in_parallel)
                                .with(urls: ['abs url1', 'abs url2'], headers: headers)
                                .and_return(mock_downloaded_files)
        subject.perform(submission_id: submission_id)
      end

      it 'gets the detail_objects from the Submission' do
        expect(submission).to receive(:detail_objects).at_least(:once).and_return(detail_objects)
        subject.perform(submission_id: submission_id)
      end

      describe 'for each detail object' do
        let(:detail_object){ detail_objects.first }
        before do
          allow(subject).to receive(:attachment_file_paths)
                          .and_return(['file1', 'file2'])
        end

        it 'retrieves the mail body parts' do
          expect(subject).to receive(:retrieve_mail_body_parts).with(detail_object, url_resolver, headers).and_return(body_part_content)
          subject.perform(submission_id: submission_id)
        end

        it 'gets the attachment_file_paths' do
          expect(subject).to receive(:attachment_file_paths)
                          .with(detail_object, mock_downloaded_files)
                          .and_return(['file1', 'file2'])
          subject.perform(submission_id: submission_id)
        end

        it 'asks the EmailService to send an email' do
          expect(EmailService).to receive(:send_mail).with(
            from: detail_object.from,
            to: detail_object.to,
            subject: detail_object.subject,
            body_parts: body_part_content,
            attachments: ['file1', 'file2']
          ).and_return(mock_send_response)
          subject.perform(submission_id: submission_id)
        end

        it 'adds the response to the submission responses' do
          subject.perform(submission_id: submission_id)
          expect(submission.responses).to eq([mock_send_response])
        end

        it 'saves the submission' do
          expect(submission).to receive(:save!)
          subject.perform(submission_id: submission_id)
        end

        it 'completes the submission' do
          subject.perform(submission_id: submission_id)
          expect(submission.status).to eq('completed')
        end
      end
    end
  end

  describe '#attachment_file_paths' do
    context 'given a mail with attachment urls' do
      let(:mail) { double('mail', attachments: ['url1', 'url2']) }
      context 'and a map of urls to file paths' do
        let(:url_file_map) { {'url1' => 'file path 1', 'url2' => 'file path 2'} }

        it 'returns the corresponding file paths' do
          expect(subject.send(:attachment_file_paths, mail, url_file_map)).to eq(
            ['file path 1', 'file path 2']
          )
        end
      end
    end
  end

  describe '#unique_attachment_urls' do
    context 'given a submission with multiple detail objects, each with attachments' do
      let(:submission_detail_1) do
        {
          'type' => 'email',
          'attachments'=>['url1', 'url2']
        }
      end
      let(:submission_detail_2) do
        {
          'type' => 'email',
          'attachments'=>['url2', 'url3']
        }
      end
      let(:submission) do
        Submission.new(submission_details: [submission_detail_1, submission_detail_2])
      end

      it 'returns a single array of unique urls' do
        expect(subject.send(:unique_attachment_urls, submission)).to eq(
          ['url1', 'url2', 'url3']
        )
      end
    end
  end

  describe '#retrieve_mail_body_parts' do
    let(:mail) { double('mail') }
    before do
      allow(subject).to receive(:download_body_parts).with(mail, url_resolver, headers).and_return(mock_downloaded_files)
      allow(subject).to receive(:read_downloaded_body_parts).with(mail, mock_downloaded_files).and_return(body_part_content)
    end
    it 'downloads the body parts' do
      expect(subject).to receive(:download_body_parts).with(mail, url_resolver, headers).and_return(mock_downloaded_files)
      subject.send(:retrieve_mail_body_parts, mail, url_resolver, headers)
    end
    it 'reads the downloaded body parts' do
      expect(subject).to receive(:read_downloaded_body_parts).with(mail, mock_downloaded_files).and_return(body_part_content)
      subject.send(:retrieve_mail_body_parts, mail, url_resolver, headers)
    end
    it 'returns the map of content type to content' do
      expect(subject.send(:retrieve_mail_body_parts, mail, url_resolver, headers)).to eq(body_part_content)
    end
  end

  describe '#download_body_parts' do
    let(:mail) { double('mail', body_parts: {'text/plain' => 'url1', 'text/html' => 'url2'}) }
    before do
      allow(DownloadService).to receive(:download_in_parallel).with(
        urls: ['abs url1', 'abs url2'],
        headers: headers
      ).and_return('download result')
    end
    it 'resolves the urls' do
      expect(url_resolver).to receive(:ensure_absolute_urls).with(['url1', 'url2']).and_return(['abs url1', 'abs url2'])
      subject.send(:download_body_parts, mail, url_resolver, headers)
    end

    it 'asks the DownloadService to download the resolved body part urls in parallel' do
      expect(DownloadService).to receive(:download_in_parallel).with(
        urls: ['abs url1', 'abs url2'],
        headers: headers
      )
      subject.send(:download_body_parts, mail, url_resolver, headers)
    end

    it 'returns the result of the download call' do
      expect(subject.send(:download_body_parts, mail, url_resolver, headers)).to eq('download result')
    end
  end

  describe '#read_downloaded_body_parts' do
    context 'given a mail with body parts' do
      let(:mail) { double('mail', body_parts: {'text/plain' => 'url1', 'text/html' => 'url2'}) }

      context 'and a map of urls to file paths' do
        let(:file_map) { {'url1' => 'file1', 'url2' => 'file2'} }
        let(:mock_file_1) { double('File1', read: 'file 1 content')}
        let(:mock_file_2) { double('File2', read: 'file 2 content')}
        before do
          allow(File).to receive(:open).with('file1').and_yield(mock_file_1)
          allow(File).to receive(:open).with('file2').and_yield(mock_file_2)
        end

        it 'reads each file' do
          expect(File).to receive(:open).with('file1').and_yield(mock_file_1)
          expect(File).to receive(:open).with('file2').and_yield(mock_file_2)
          subject.send(:read_downloaded_body_parts, mail, file_map)
        end

        it 'returns a map of content types to file content' do
          expect(subject.send(:read_downloaded_body_parts, mail, file_map)).to eq(
            'text/plain' => 'file 1 content', 'text/html' => 'file 2 content'
          )
        end
      end
    end
  end

end
