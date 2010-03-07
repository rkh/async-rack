require "rack/lock"

module AsyncRack
  class Lock < AsyncCallback(:Lock)
    def async_callback(result)
      raise RuntimeError, "does not support async.callback"
    end
  end
end
