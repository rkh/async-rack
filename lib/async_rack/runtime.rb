require "rack/runtime"

module AsyncRack
  class Runtime < AsyncCallback(:Runtime)
    def async_callback(result)
      status, headers, body =result
      request_time = Time.now - @start_time
      headers[@header_name] = "%0.6f" % request_time if !headers.has_key?(@header_name)
      super [status, headers, body]
    end

    def call(env)
      @start_time = Time.now
      super
    end
  end
end