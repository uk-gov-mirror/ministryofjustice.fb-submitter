require_relative '../../app/services/generate_csv_content'

describe GenerateCsvContent do
  subject { described_class.new(payload: payload) }

  let(:payload) do
    { submission: submission }
  end

  let(:submission) do
    {
      serviceSlug: 'fix-my-court',
      submission_id: '11111111-1111-1111-1111-111111111111',
      submissionAnswers: {
        auto_name__1: "yes",
        auto_name__2: "user@example.com",
      }
    }
  end

  context 'when requesting a csv with a submission' do
    it 'returns an Attachment object' do
      result = subject.execute
      expect(result.class).to eq(Attachment)
    end

    it 'assigns the correct info the the Attachment object' do
      result = subject.execute

      expect(result.filename).to eq('11111111-1111-1111-1111-111111111111-answers.csv')
      expect(result.mimetype).to eq('text/csv')

      file_contents = File.open(result.path).read
      csv = CSV.new(file_contents).read

      expect(csv[0]).to eql(['slug', 'submission_id', 'auto_name__1', 'auto_name__2'])
      expect(csv[1]).to eql(['fix-my-court', '11111111-1111-1111-1111-111111111111', 'yes', 'user@example.com'])
    end
  end
end
