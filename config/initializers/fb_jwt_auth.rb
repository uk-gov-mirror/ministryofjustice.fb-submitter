Fb::Jwt::Auth.configure do |config|
  config.service_token_cache_root_url = ENV['SERVICE_TOKEN_CACHE_ROOT_URL']
  config.service_token_cache_api_version = :v3
end
