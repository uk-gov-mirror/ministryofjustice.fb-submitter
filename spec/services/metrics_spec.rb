require 'rails_helper'

describe Metrics do
  let(:fake_client) do
    Class.new do
      def initialize; end

      def track(id, event_name, properties); end

      def can_track?; end
    end
  end
  let(:object) { OpenStruct.new(id: 1) }
  let(:client) { fake_client.new }

  describe '#track' do
    subject(:metrics) { described_class.new(object, client) }

    let(:event_name) { 'Submission' }
    let(:properties) { { form: 'fix-my-court' } }

    context 'when tracking is successful' do
      it 'calls track on the client object' do
        allow(client).to receive(:can_track?).and_return(true)
        allow(client).to receive(:track).with(1, event_name, properties)
        metrics.track(event_name, properties)
        expect(client).to have_received(:track)
      end
    end

    context 'when metrics client can not track' do
      let(:client) { spy }

      it 'does not track events' do
        allow(client).to receive(:can_track?).and_return(false)
        metrics.track(event_name, properties)
        expect(client).not_to have_received(:track)
      end
    end

    context 'when tracking fails' do
      it 'sends exception to sentry' do
        allow(client).to receive(:can_track?).and_return(true)
        allow(client).to receive(:track).and_raise(StandardError)
        allow(Raven).to receive(:capture_exception)
        metrics.track(event_name, properties)
        expect(Raven).to have_received(:capture_exception)
      end
    end
  end
end
