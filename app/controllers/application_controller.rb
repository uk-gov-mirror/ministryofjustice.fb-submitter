class ApplicationController < ActionController::API
  include Concerns::ErrorHandling
  include Concerns::JWTAuthentication
  include Concerns::ContentNegotiation
end
