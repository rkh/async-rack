SPEC = Gem::Specification.new do |s|

  # Get the facts.
  s.name             = "async-rack"
  s.version          = "0.4.0.d"
  s.description      = "Makes middleware that ships with Rack bullet-proof for async responses."

  # External dependencies
  s.add_dependency "rack", ">= 1.1.0"
  s.add_development_dependency "rspec", ">= 1.3.0"

  # Those should be about the same in any BigBand extension.
  s.authors          = ["Konstantin Haase"]
  s.email            = "konstantin.mailinglists@googlemail.com"
  s.files            = Dir["**/*.{rb,md}"]
  s.has_rdoc         = 'yard'
  s.homepage         = "http://github.com/rkh/#{s.name}"
  s.require_paths    = ["lib"]
  s.summary          = s.description
  
end

