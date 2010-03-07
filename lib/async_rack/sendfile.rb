require "rack/sendfile"

module AsyncRack
  class Sendfile < AsyncCallback(:Sendfile)
    include AsyncRack::AsyncCallback::SimpleWrapper
  end
end
