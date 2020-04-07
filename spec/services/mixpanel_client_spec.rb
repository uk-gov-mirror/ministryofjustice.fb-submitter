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
      context 'when env is production' do
        it 'returns true' do
          client.metrics_access_key = 'foo'
          client.deployment_env = 'live-production'
          expect(client).to be_can_track
        end
      end

      context 'when env is not production' do
        it 'returns false' do
          client.metrics_access_key = 'foo'
          client.deployment_env = 'live-dev'
          expect(client).not_to be_can_track
        end
      end
    end

    context 'when mixpanel access token is blank' do
      context 'when is nil' do
        it 'returns false' do
          client.metrics_access_key = nil
          expect(client).not_to be_can_track
        end
      end

      context 'when is blank' do
        it 'returns false' do
          client.metrics_access_key = ''
          expect(client).not_to be_can_track
        end
      end
    end
  end
end
