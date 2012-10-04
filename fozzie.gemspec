# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "fozzie/version"

Gem::Specification.new do |s|
  s.name        = "fozzie"
  s.version     = Fozzie::VERSION
  s.authors     = ["Marc Watts"]
  s.email       = ["marc.watts@lonelyplanet.co.uk"]
  s.summary     = %q{Ruby gem from Lonely Planet Online to register statistics. Currently supports Statsd.}
  s.description = %q{
    Gem to make statistics sending from Ruby applications simple and efficient as possible.
    Currently supports Statsd, and is inspired by the original ruby-statsd gem by Etsy.
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
  s.add_development_dependency 'guard'
  s.add_development_dependency 'rb-inotify'
  s.add_development_dependency 'guard-rspec'
  s.add_development_dependency 'sinatra'
  s.add_development_dependency 'rack-test'
  s.add_development_dependency 'actionpack'
  s.add_development_dependency 'railties'
end
