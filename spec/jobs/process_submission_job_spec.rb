require 'rails_helper'

describe ProcessSubmissionJob do
  describe '#perform' do
    let(:submission_id) { rand(10000) }
    let(:service) { double(:service) }

    it 'calls service correctly' do
      expect(ProcessSubmissionService).to receive(:new).with(submission_id: submission_id).and_return(service)
      expect(service).to receive(:perform)

      subject.perform(submission_id: submission_id)
    end
  end
end
