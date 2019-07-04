module Resque
  module Failure
    class Sentry < Base
      def save
        Raven.capture_exception(exception)
      end
    end
  end
end
