module Requests
  module JsonHelpers
    def json
      JSON.parse(body.to_s)
    end
  end
end
