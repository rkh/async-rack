module AsyncRack

  ##
  # @see AsyncRack::AsyncCallback
  def self.AsyncCallback(name, namespace = Rack)
    @wrapped ||= Hash.new { |h,k| h[k] = {} }
    @wrapped[namespace][name.to_sym] ||= namespace.const_get(name).tap do |klass|
      klass.extend AsyncCallback::InheritanceHook
      klass.alias_subclass name, namespace
    end
  end

  ##
  # Helps wrapping already existent middleware in a transparent manner.
  #
  # @example
  #   module Rack
  #     class FancyMiddleware
  #     end
  #   end
  #
  #   module AsyncRack
  #     class FancyMiddleware < AsyncCallback(:FancyMiddleware)
  #     end
  #   end
  #
  #   Rack::FancyMiddleware # => AsyncRack::FancyMiddleware
  #   AsyncRack::FancyMiddleware.ancestors # => [AsyncRack::AsyncCallback::Mixin, Rack::FancyMiddleware, ...]
  module AsyncCallback
    def self.included(mod)
      mod.send :include, Mixin
      super
    end

    ##
    # Aliases a subclass on subclassing, but only once.
    # If that name already is in use, it will be replaced.
    #
    # @example
    #   class Foo
    #     def self.bar
    #       23
    #     end
    #   end
    #
    #   Foo.extend AsyncRack::AsyncCallback::InheritanceHook
    #   Foo.alias_subclass :Baz
    #
    #   class Bar < Foo
    #     def self.bar
    #       super + 19
    #     end
    #   end
    #
    #   Baz.bar # => 42
    module InheritanceHook

      ##
      # @param [Symbol] name Name it will be aliased to
      # @param [Class, Module] namespace The module the constant will be defined in
      def alias_subclass(name, namespace = Object)
        @alias_subclass = [name, namespace]
      end

      ##
      # @see InheritanceHook
      def inherited(klass)
        super
        if @alias_subclass
          name, namespace = @alias_subclass
          @alias_subclass = nil
          namespace.send :remove_const, name if namespace.const_defined? name
          namespace.const_set name, klass
          klass.send :include, AsyncRack::AsyncCallback::Mixin
        end
      end
    end

    module LateInitializer
      def included(klass)
        setup_late_initialize klass if klass.is_a? Class
        klass.extend LateInitializer
        super
      end

      private
      def setup_late_initialize(klass)
        class << klass
          def new(app, *args, &block)
            return super(*args, &block) if app == false
            proc { |env| new(false, app, *args, &block).call(env) }
          end
        end
      end
    end

    module Mixin
      extend LateInitializer
      attr_accessor :env

      def async_callback(result)
        @async_callback.call result
      end

      def setup_async(env)
        return false if @async_callback
        @async_callback = env['async.callback']
        env['async.callback'] = method :async_callback
        @env = env
      end

      def call(env)
        setup_async env
        super
      end
    end

    ##
    # A simple wrapper is useful if the first thing a middleware does is something like
    # @app.call and then modifies the response.
    #
    # In that case you just have to include SimpleWrapper in your async wrapper class.
    module SimpleWrapper
      include AsyncRack::AsyncCallback::Mixin
      def async_callback(result)
        @app = proc { result }
        super call(@env)
      end
    end
  end
end