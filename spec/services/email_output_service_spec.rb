require_relative '../../app/services/email_output_service'
require_relative '../../app/services/email_service'
require_relative '../../app/services/attachment_generator'
require_relative '../../app/value_objects/attachment'

describe EmailOutputService do
  subject(:service) do
    described_class.new(
      emailer: email_service_mock,
      attachment_generator: attachment_generator
    )
  end

  let(:email_service_mock) { class_double(EmailService) }
  let(:attachment_generator) { AttachmentGenerator.new }

  let(:email_action) do
    {
      recipientType: 'team',
      type: 'email',
      from: 'form-builder@digital.justice.gov.uk',
      to: 'bob.admin@digital.justice.gov.uk',
      subject: 'Complain about a court or tribunal submission',
      email_body: 'Please find an application attached',
      include_pdf: include_pdf,
      include_attachments: include_attachments
    }
  end

  let(:include_pdf) { false }
  let(:include_attachments) { false }

  let(:upload1) { build(:attachment) }
  let(:upload2) { build(:attachment) }
  let(:upload3) { build(:attachment) }

  let(:attachments) do
    [upload1, upload2, upload3]
  end

  let(:pdf_attachment) { build(:attachment, mimetype: 'application/pdf', url: nil) }

  before do
    allow(upload1).to receive(:size).and_return(1234)
    allow(upload2).to receive(:size).and_return(5678)
    allow(upload3).to receive(:size).and_return(9_999_999)
    allow(pdf_attachment).to receive(:size).and_return(7777)

    allow(email_service_mock).to receive(:send_mail)
    subject.execute(action: email_action,
                    attachments: attachments,
                    pdf_attachment: pdf_attachment,
                    submission_id: 'an-id-2323')
  end

  it 'execute sends an email' do
    expect(email_service_mock).to have_received(:send_mail).with(to: 'bob.admin@digital.justice.gov.uk',
                                                                 from: 'form-builder@digital.justice.gov.uk',
                                                                 subject: 'Complain about a court or tribunal submission {an-id-2323} [1/1]',
                                                                 body_parts: { 'text/plain': 'Please find an application attached' },
                                                                 attachments: []).once
  end

  context 'when a user uploaded attachments are required but not answers pdf' do
    let(:include_attachments) { true }

    it 'groups attachments into emails up to maximum limit' do
      first_email_attachments = [upload1, upload2]
      second_email_attachments = [upload3]

      expect(email_service_mock).to have_received(:send_mail).exactly(2).times
      expect(email_service_mock).to have_received(:send_mail).with(hash_including(attachments: first_email_attachments)).once
      expect(email_service_mock).to have_received(:send_mail).with(hash_including(attachments: second_email_attachments)).once
    end

    it 'the subject is numbered by how many separate emails there are' do
      expect(email_service_mock).to have_received(:send_mail).with(hash_including(subject: 'Complain about a court or tribunal submission {an-id-2323} [1/2]')).once
      expect(email_service_mock).to have_received(:send_mail).with(hash_including(subject: 'Complain about a court or tribunal submission {an-id-2323} [2/2]')).once
    end
  end

  context 'when a user answers pdf is needed but not uploaded attachments' do
    let(:include_pdf) { true }

    it 'sends an email with the generated pdf as a attachment' do
      expect(email_service_mock).to have_received(:send_mail).exactly(1).times
      expect(email_service_mock).to have_received(:send_mail).with(hash_including(attachments: [pdf_attachment])).once
    end

    it 'the subject is numbered [1/1] as there will be a single email' do
      expect(email_service_mock).to have_received(:send_mail).with(hash_including(subject: 'Complain about a court or tribunal submission {an-id-2323} [1/1]')).once
    end
  end

  context 'when both uploaded attachments and answers pdf are required' do
    let(:include_attachments) { true }
    let(:include_pdf) { true }

    it 'groups attachments per email, pdf submission first remainder based on attachment size, ' do
      first_email_attachments = [pdf_attachment, upload1, upload2]
      second_email_attachments = [upload3]

      expect(email_service_mock).to have_received(:send_mail).exactly(2).times
      expect(email_service_mock).to have_received(:send_mail).with(hash_including(attachments: first_email_attachments)).once
      expect(email_service_mock).to have_received(:send_mail).with(hash_including(attachments: second_email_attachments)).once
    end
  end
end
