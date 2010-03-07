require "rack/conditionalget"

module AsyncRack
  class ConditionalGet < AsyncCallback(:ConditionalGet)
    include AsyncRack::AsyncCallback::SimpleWrapper
  end
end
