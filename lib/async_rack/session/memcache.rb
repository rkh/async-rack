require "rack/session/memcache"

module AsyncRack
  module Session
    class Memcache < AsyncRack::AsyncCallback(:Memcache, Rack::Session)
      def async_callback(result)
        super commit_session(env, *result)
      end
    end
  end
end
