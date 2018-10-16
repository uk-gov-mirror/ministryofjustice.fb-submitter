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
    let(:mock_send_response){ {'key' => 'send response'} }
    before do
      allow(submission).to receive(:detail_objects).and_return(detail_objects)
      allow(EmailService).to receive(:send).and_return( mock_send_response )
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

      describe 'for each detail object' do
        let(:detail_object){ detail_objects.first }
        before do
          allow(subject).to receive(:attachment_file_paths)
                          .and_return(['file1', 'file2'])
        end

        it 'retrieves the mail body parts' do
          expect(subject).to receive(:retrieve_mail_body_parts).with(detail_object).and_return(body_part_content)
          subject.perform(submission_id: submission_id)
        end

        it 'gets the attachment_file_paths' do
          expect(subject).to receive(:attachment_file_paths)
                          .with(detail_object, mock_downloaded_files)
                          .and_return(['file1', 'file2'])
          subject.perform(submission_id: submission_id)
        end

        it 'asks the EmailService to send an email' do
          expect(EmailService).to receive(:send).with(
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
end
