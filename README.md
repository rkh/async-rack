# AsyncRack

## Note upfront
Still experimental. Feel free to play around.

## Introduction
So, have you been amazed by thin's `async.callback`? If not, [go](http://macournoyer.com/blog/2009/06/04/pusher-and-async-with-thin/) [check](http://github.com/raggi/async_sinatra) [it](http://github.com/raggi/thin/blob/async_for_rack/example/async_app.ru) [out](http://m.onkey.org/2010/1/7/introducing-cramp). Come back here when you start missing your middleware.

So what is the issue with Rack and `async.callback`? Currently there are two ways of triggering a async responds. The first is to `throw :async`, the latter to return a status code of -1 (even though thin and ebb do disagree on that). Opposed to what others say, I would recommend using `throw`, as it simply skips middleware not able to handle `:async`. Also, it works on all servers supporting `async.callback` – thin, ebb, rainbows! and zbatery – about the same and copes better with middleware that is unable to handle an async respond.

That's the issue with async.callback: Most middleware is not aware of it. Let's say you got an app somewhat like that:

    class Farnsworth
      def when_there_is_good_news
        Thread.new do # Well, actually, you want to hook into your event loop instead, I guess.
          wait_for_good_news
          yield
        end
      end
      
      def call(env)
        when_there_is_good_news do
          env["async.callback"].call [200, {'Content-Type' => 'text/plain'}, ['Good news, everyone!']]
        end
        throw :async
      end
    end

Ok, now, since this app could end up on Reddit, you better prepare yourself for some heavy traffic. Say, you want to use the `Rack::Deflate` middleware, so you set it up in your config.ru and add the link to reddit yourself. The next day you get a call from your server admin. Why don't you at least compress your http response? Well what happened? The problem is, that by sending your response via `env["async.callback"].call` you talk directly to your web server (i.e. thin), bypassing all potential middleware.

Well, how do you avoid that? Simple: By just using middleware that plays well with `async.callback`. However, most middleware does not play well with it. In fact, most middleware that ships with rack does not play well with it. That's what I wrote this little library for. If you load `async-rack` it modifies all middleware that ships with rack, so it will work just fine with you throwing around your :async.

How does that work? Simple, whenever necessary, `async-rack` will replace `async.callback` with an appropriate proc object, so it has the chance to do it's response modifications whenever you feel like answering the http request.

Note: This library only 'fixes' the middleware that ships with rack, not other rack middleware. However, you can use the included helper classes to easily make other libraries handle `async.callback`.

## What's in this package?

### Rack middleware made async-proof
This middleware now works well with `throw :async`:

* Rack::Chunked
* Rack::CommonLogger
* Rack::ConditionalGet
* Rack::ContentLength
* Rack::ContentType
* Rack::Deflater
* Rack::ETag
* Rack::Head
* Rack::Logger
* Rack::Runtime
* Rack::Sendfile
* Rack::ShowStatus

### Middleware that is async-proof out of the box
No changes where necessary for:

* Rack::Cascade
* Rack::Config
* Rack::Directory
* Rack::File
* Rack::MethodOverride
* Rack::Mime
* Rack::NullLogger
* Rack::Recursive
* Rack::Reloader
* Rack::Static
* Rack::URLMap

### Middleware not (yet) made async-proof

* Rack::Lint (might not check async responses)
* Rack::ShowExceptions (might not show exceptions for async responses)
* Rack::Lock (might raise an exception)

## How to make a middleware async-proof?
There are three types of middleware:

### Middleware doing stuff before handing on the request
Example: `Rack:::MethodOverride`

Such middleware already works fine with `async.callback`. Also, from our perspective, middleware either creating a own response and not calling your app at all, or calling your app without modifying neither request nor response falls into this category, too.

Such middleware can easily be identified by having `@app.call(env)` or something similar as last line or always prefixed with a `return` inside the `call` method.

### Middleware doing stuff after handing on the request
Example: `Rack:::ETag`

Here it is a bit tricky. Essentially what you want is running `#call` again on an `async.callback` but replace `@app.call(env)` with the parameter passed to `async.callback`. Well, apparently this is the most common case inside rack, so I created a mixin for that:

    # Ok, Rack::FancyStuff does currently not work with async responses
    require 'rack/fancy_stuff'
    
    class FixedFancyStuff < AsyncRack::AsyncCallback(:FancyStuff)
      include AsyncRack::AsyncCallback::SimpleWrapper
    end

See below to get an idea what actually happens here.

### Middleware meddling with both your request and your response
Example: `Rack::Runtime`

    # Let's assume there is some not so async middleware.
    module Rack
      class FancyStuff
        def initialize(app)
          @app = app
        end
        
        def call(env)
          prepare_fancy_stuff env
          result = @app.call env
          perform_fancy_stuff result
        end
        
        def prepare_fancy_stuff(env)
          # ...
        end
        
        def perform_fancy_stuff(result)
          # ...
        end
      end
    end
    
    # What happens here is the following: We will subclass Rack::FancyStuff
    # and then set Rack::FancyStuff = FixedFancyStuff. AsyncRack::AsyncCallback
    # makes sure we don't screw that up.
    class FixedFancyStuff < AsyncRack::AsyncCallback(:FancyStuff)
      # this method will handle async.callback
      def async_callback(result)
        # pass it on to thin / ebb / other middleware
        super perform_fancy_stuff(result)
      end
    end
    
    Rack::FancyStuff == FixedFancyStuff # => true

## Setup
In general: Place a `require 'async-rack'` before setting up any middleware or you will end up with the synchronous version!

Please keep in mind that it only "fixes" middleware that ships with rack. Read: It works very well with Sinatra. With Rails and Merb, not so much!

### With Rack
In your `config.ru`:

    require 'async-rack'
    require 'your-app'
    
    use Rack::SomeMiddleware
    run YourApp

### With Sinatra
In your application file:

    require 'async-rack'
    require 'sinatra'
    
    get '/' do
      # do some async stuff here
    end

### With Rails 2.x
In your `config/environment.rb`, add inside the `Rails::Initializer.run` block:

    config.gem 'async-rack'

### With Rails 3.x
In your `Gemfile`, add:

    gem 'async-rack'
