require "bundler/gem_tasks"

spec = Gem::Specification.load("http_log_parser.gemspec")

require 'rake/testtask'
Rake::TestTask.new do |t|
  t.test_files = spec.test_files
end

require 'rubygems/package_task'
Gem::PackageTask.new(spec) do |pkg|
  pkg.need_zip = true
  pkg.need_tar = true
end

require 'rdoc/task'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'HttpLogParser'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

task :default => "pkg/#{spec.name}-#{spec.version}.gem" do
  puts "now> gem push pkg/#{spec.name}-#{spec.version}.gem"
end
