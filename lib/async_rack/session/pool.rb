require "rack/session/pool"

module AsyncRack
  module Session
    class Pool < AsyncRack::AsyncCallback(:Pool, Rack::Session)
      def async_callback(result)
        super commit_session(env, *result)
      end
    end
  end
end
