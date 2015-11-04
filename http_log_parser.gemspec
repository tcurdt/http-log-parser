# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.summary          = "A tiny library for parsing web server logs."
  s.description      = "HTTP log file parser"
  s.platform         = Gem::Platform::RUBY
  s.name             = "http-log-parser"
  s.version          = "1.0.0"
  s.author           = "Torsten Curdt"
  s.email            = "tcurdt at vafer.org"
  s.licenses         = [ 'MIT' ]
  s.homepage         = "http://github.com/tcurdt/http-log-parser"
  s.has_rdoc         = true
  s.extra_rdoc_files = [ "README.rdoc" ]
  s.require_path     = "lib"
  s.files            = Dir.glob("lib/**/*") + %w(README.rdoc Rakefile)
  s.test_files       = Dir.glob("test/**/*")

  s.required_ruby_version = "~> 1.8"

  s.add_development_dependency 'rake', '~> 10.4'
  s.add_development_dependency 'test-unit', '~> 3.1'

end