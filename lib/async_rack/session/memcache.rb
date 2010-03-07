require "rack/memcache"

module AsyncRack
  module Session
    class Memcache < AsyncCallback(:Memcache, Rack::Session)
      def async_callback(result)
        super commit_session(@env, *result)
      end
    end
  end
end
