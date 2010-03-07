require "rack/chunked"

module AsyncRack
  class Chunked < AsyncCallback(:Chunked)
    include AsyncRack::AsyncCallback::SimpleWrapper
  end
end