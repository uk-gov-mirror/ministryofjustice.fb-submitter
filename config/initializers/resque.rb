# Establish a connection between Resque and Redis
url = (ENV["REDISCLOUD_URL"] || ENV['REDIS_URL'])

begin
  uri_with_protocol = (ENV['REDIS_PROTOCOL'] || 'redis://') + url.to_s
  uri = URI.parse(uri_with_protocol)
  Resque.redis = Redis.new(
    url: uri_with_protocol,
    password: ENV['REDIS_AUTH_TOKEN']
  )
rescue URI::InvalidURIError
  puts "could not parse a valid Redis URI from #{url} - falling back to file log"
end

require 'resque/failure/multiple'
require 'resque/failure/redis'
require 'resque/failure/sentry'

Resque::Failure::Multiple.classes = [Resque::Failure::Redis, Resque::Failure::Sentry]
Resque::Failure.backend = Resque::Failure::Multiple
