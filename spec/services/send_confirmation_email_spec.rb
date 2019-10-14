require_relative '../../app/services/send_confirmation_email'

describe SendConfirmationEmail do
  subject(:send_confirmation_email_service) do
    described_class.new(
      email_service: EmailService,
      save_temp_pdf_service: attach_pdf_service
    )
  end

  let(:attach_pdf_service) { instance_double('PdfAttachments', execute: '/tmp/my-file.pdf') }
  let(:submission) { {} }
  let(:from) { 'bob@some-government-organisation.com' }
  let(:to) { 'sally@example.com' }
  let(:email_subject) { 'thanks for filling out our form' }

  before do
    allow(EmailService).to receive(:send_mail)

    send_confirmation_email_service.execute(
      from: from,
      to: to,
      subject: email_subject,
      submission_id: '123456'
    )
  end

  context 'when sending a confirmation email' do
    it 'fetches the temp file locations from the pdf attachments service' do
      expect(attach_pdf_service).to have_received(:execute)
    end

    it 'calls send_mail on the EmailService' do
      expect(EmailService).to have_received(:send_mail).with(from: from, to: to, subject: email_subject, attachments: ['/tmp/my-file.pdf'])
    end
  end
end
