module Filters
  class AuthenticateApplication
    def self.before(controller)
      token = controller.request.authorization.to_s.gsub(/^Bearer /, '')
      Fb::Jwt::Auth.new(
        token: token,
        leeway: ENV['MAX_IAT_SKEW_SECONDS'].to_i,
        logger: Rails.logger
      ).verify!
    end
  end
end
