require "rack/cookie"

module AsyncRack
  module Session
    class Cookie < AsyncCallback(:Cookie, Rack::Session)
      def async_callback(result)
        super commit_session(@env, *result)
      end
    end
  end
end
