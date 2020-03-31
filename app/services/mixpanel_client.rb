require 'mixpanel-ruby'

class MixpanelClient
  attr_reader :metrics_access_key, :tracker
  delegate :track, to: :tracker

  def initialize
    @metrics_access_key = ENV['METRICS_ACCESS_KEY']
    @tracker = Mixpanel::Tracker.new(metrics_access_key)
  end

  def can_track?
    @metrics_access_key.present?
  end
end
