# AsyncRack

## Usage
In general: Place a `require 'async-rack'` before setting up any middleware or you will end up with the synchronous version!

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
