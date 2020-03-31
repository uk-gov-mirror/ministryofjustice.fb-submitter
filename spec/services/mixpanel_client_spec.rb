require 'rails_helper'

describe MixpanelClient do
  subject(:client) { described_class.new }

  describe '#tracker' do
    it 'returns a mixpanel tracker' do
      expect(client.tracker).to be_a(Mixpanel::Tracker)
    end
  end

  describe '#can_track?' do
    context 'when mixpanel access token is present' do
      it 'returns true' do
        allow(ENV).to receive(:[]).with('METRICS_ACCESS_KEY').and_return('foo')
        expect(client).to be_can_track
      end
    end

    context 'when mixpanel access token is blank' do
      it 'returns false' do
        allow(ENV).to receive(:[]).with('METRICS_ACCESS_KEY').and_return(nil)
        expect(client).not_to be_can_track
      end
    end
  end
end
