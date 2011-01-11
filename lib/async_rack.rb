require "rack"
require "async_rack/async_callback"

module AsyncRack
  module BaseMixin
    ::Rack.extend self
    ::Rack::Session.extend self
    def autoload(class_name, path)
      super unless autoload?(class_name) =~ /async_rack/
    end
  end

  module ExtensionMixin
    ::AsyncRack.extend self
    def autoload(class_name, path)
      mod = Rack
      mod_path = self.name.split("::")
      mod_path.shift
      while (mod_ = mod_path.shift)
        mod = mod.const_get(mod_.to_sym)
      end
      # already loaded ? override.
      if mod.autoload?(class_name) == nil
        require path
      else
        mod.autoload class_name, path
        super
      end
    end
  end

  # New middleware
  autoload :CatchAsync,     "async_rack/catch_async"
  autoload :ThrowAsync,     "async_rack/throw_async"

  # Wrapped rack middleware
  autoload :Chunked,        "async_rack/chunked"
  autoload :CommonLogger,   "async_rack/commonlogger"
  autoload :ConditionalGet, "async_rack/conditionalget"
  autoload :ContentLength,  "async_rack/content_length"
  autoload :ContentType,    "async_rack/content_type"
  autoload :Deflater,       "async_rack/deflater"
  autoload :ETag,           "async_rack/etag"
  autoload :Head,           "async_rack/head"
  autoload :Lock,           "async_rack/lock"
  autoload :Logger,         "async_rack/logger"
  autoload :Runtime,        "async_rack/runtime"
  autoload :Sendfile,       "async_rack/sendfile"
  autoload :ShowStatus,     "async_rack/showstatus"

  module Session
    extend ExtensionMixin
    autoload :Cookie,   "async_rack/session/cookie"
    autoload :Pool,     "async_rack/session/pool"
    autoload :Memcache, "async_rack/session/memcache"
  end

end
