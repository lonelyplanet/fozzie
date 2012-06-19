# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "fozzie/version"

Gem::Specification.new do |s|
  s.name        = "fozzie"
  s.version     = Fozzie::VERSION
  s.authors     = ["Marc Watts", "Dave Nolan"]
  s.email       = ["marc.watts@lonelyplanet.co.uk"]
  s.summary     = %q{Statsd Ruby gem from Lonely Planet Online}
  s.description = %q{
    Gem to make statistics sending to Statsd from Ruby applications simple and efficient as possible.
    Inspired by the original ruby-statsd gem by Etsy, currently used by Lonely Planet Online.
  }

  s.rubyforge_project = "fozzie"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'sys-uname'
  s.add_dependency 'facets'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'mocha'
  s.add_development_dependency 'syntax'
  s.add_development_dependency 'simplecov'

  s.add_development_dependency 'sinatra'
  s.add_development_dependency 'rack-test'
  s.add_development_dependency 'actionpack', '2.3.14'

  s.add_development_dependency 'guard'
  s.add_development_dependency 'guard-rspec'

  s.add_development_dependency 'ruby_gntp'
end
