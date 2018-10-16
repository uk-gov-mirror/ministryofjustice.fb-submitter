require 'rails_helper'

describe ProcessSubmissionJob do
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
        status: 'queued',
        submission_details: [submission_detail]
      )
    end
    let(:detail_objects) do
      [EmailSubmissionDetail.new(submission_detail)]
    end
    let(:urls) { ['url1', 'url2'] }
    let(:mock_downloaded_files) { {'url1' => 'file1', 'url2' => 'file2'} }
    let(:downloaded_body_parts) { mock_downloaded_files }
    let(:body_part_content) do
      {
        'text/plain' => 'some plain text',
        'text/html' => '<html>some html</html>'
      }
    end
    before do
      allow(EmailService).to receive(:send).and_return( {'key' => 'send response'} )
      allow(DownloadService).to receive(:download_in_parallel).and_return(
        mock_downloaded_files
      )
      allow(subject).to receive(:download_body_parts).and_return(downloaded_body_parts)
      allow(subject).to receive(:read_downloaded_body_parts).and_return(body_part_content)
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

      it 'downloads the unique_attachment_urls in parallel' do
        expect(DownloadService).to receive(:download_in_parallel)
                                .with(urls: ['https://tools.ietf.org/pdf/rfc2324'])
                                .and_return(mock_downloaded_files)
        subject.perform(submission_id: submission_id)
      end

      it 'gets the detail_objects from the Submission' do
        expect(submission).to receive(:detail_objects).at_least(:once).and_return(detail_objects)
        subject.perform(submission_id: submission_id)
      end
    end
  end
end
