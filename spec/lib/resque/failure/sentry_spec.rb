require 'rails_helper'

RSpec.describe Resque::Failure::Sentry do
  describe '#save' do
    let(:exception) do
      StandardError.new('foo')
    end

    let(:worker) { double('worker') }
    let(:queue) { double('queue') }
    let(:payload) { double('payload') }

    subject do
      described_class.new(exception, worker, queue, payload)
    end

    it 'notifies sentry' do
      expect(Raven).to receive(:capture_exception).with(exception)

      subject.save
    end
  end
end
