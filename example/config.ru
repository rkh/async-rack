$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'async-rack'

use Rack::ETag
use Rack::Runtime

run proc { |env|
  EventMachine.next_tick { env['async.callback'].call [200, {'Content-Type' => 'text/plain'}, "yay, async!"] }
  throw :async
}
