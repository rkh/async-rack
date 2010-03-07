require "rack/etag"

module AsyncRack
  class ETag < AsyncCallback(:ETag)
    include AsyncRack::AsyncCallback::SimpleWrapper
  end
end
