require 'mixpanel-ruby'

class MixpanelClient
  attr_accessor :metrics_access_key, :deployment_env, :tracker
  delegate :track, to: :tracker

  MEASURED_ENVS = [
    'live-production'
  ].freeze

  def initialize
    @metrics_access_key = ENV['METRICS_ACCESS_KEY']
    @deployment_env = ENV['FB_ENVIRONMENT_SLUG']
    @tracker = Mixpanel::Tracker.new(metrics_access_key)
  end

  def can_track?
    metrics_access_key.present? && MEASURED_ENVS.include?(deployment_env)
  end
end
