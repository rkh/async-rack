require "rack/deflater"

module AsyncRack
  class Deflater < AsyncCallback(:Deflater)
    include AsyncRack::AsyncCallback::SimpleWrapper
  end
end
