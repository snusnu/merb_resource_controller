require 'rubygems'
require 'rake/gempackagetask'

require 'merb-core'
require 'merb-core/tasks/merb'
require "spec/rake/spectask"

GEM_NAME = "merb_resource_controller"
GEM_VERSION = "0.1.0"
AUTHOR = "Martin Gamsjaeger"
EMAIL = "gamsnjaga@gmail.com"
HOMEPAGE = "http://merbivore.com/"
SUMMARY = "A merb plugin that provides the default restful actions for controllers."

spec = Gem::Specification.new do |s|
  
  s.rubyforge_project = 'merb_resource_controller'
  s.name = GEM_NAME
  s.version = GEM_VERSION
  s.platform = Gem::Platform::RUBY
  s.has_rdoc = false
  s.extra_rdoc_files = [ "LICENSE", 'TODO']
  s.summary = SUMMARY
  s.description = s.summary
  s.author = AUTHOR
  s.email = EMAIL
  s.homepage = HOMEPAGE
  s.require_path = 'lib'
  
  # be extra picky so that no coverage info and such gets included
  s.files = %w(LICENSE README.textile Rakefile TODO) + 
    Dir.glob("{lib,spec}/**/*.rb") + 
    Dir.glob("{spec}/**") + 
    Dir.glob("{spec}/**/*.rb") + 
    Dir.glob("{spec}/**/*.yml") +
    Dir.glob("{spec}/**/*.opts") +
    Dir.glob("{spec}/**/*.html.erb") +
    [ "spec/mrc_test_app/Rakefile"]
  
  # runtime dependencies
  s.add_dependency('merb-core', '~> 1.0')
  
  # development dependencies
  # if these are desired, install with:
  # gem install merb_resource_controller --development
  s.add_development_dependency('merb-assets',    '~>1.0')
  s.add_development_dependency('merb-helpers',   '~>1.0')
  s.add_development_dependency('dm-core',        '~>0.9.8')
  s.add_development_dependency('dm-validations', '~>0.9.8')
  s.add_development_dependency('dm-serializer',  '~>0.9.8')
  s.add_development_dependency('dm-constraints', '~>0.9.8')
  
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec
end

desc "install the plugin as a gem"
task :install do
  Merb::RakeHelper.install(GEM_NAME, :version => GEM_VERSION)
end

desc "Uninstall the gem"
task :uninstall do
  Merb::RakeHelper.uninstall(GEM_NAME, :version => GEM_VERSION)
end

desc "Create a gemspec file"
task :gemspec do
  File.open("#{GEM_NAME}.gemspec", "w") do |file|
    file.puts spec.to_ruby
  end
end

desc 'Default: run spec examples'
task :spec do 
  puts "!!! README !!! Run 'rake spec' from the './spec/mrc_test_app' directory to run all specs for merb_resource_controller."
end

task :default => 'spec'