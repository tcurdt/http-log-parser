require 'rubygems'
require 'rake/gempackagetask'
require 'rake/rdoctask'

spec = Gem::Specification.new do |s|
    s.name      =   "http-log-parser"
    s.version   =   "0.0.1"
    s.author    =   "Torsten Curdt"
    s.email     =   "tcurdt at vafer.org"
    s.homepage  =   "http://github.com/tcurdt/http-log-parser"
    s.description = "HTTP log file parser"
    s.summary   =   "A package for parsing web server logs."

    s.platform  =   Gem::Platform::RUBY
    s.has_rdoc  =   true
    s.extra_rdoc_files  =   ["README.rdoc"]

    s.require_path  =   "lib"
    s.files     =   %w(README.rdoc Rakefile) + Dir.glob("lib/**/*")
end

Rake::GemPackageTask.new(spec) do |pkg|
    pkg.need_tar = true
end

Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'HttpLogParser'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

task :default => "pkg/#{spec.name}-#{spec.version}.gem" do
    puts "generated latest version"
end