$:.push File.join(File.dirname(__FILE__), '..', 'lib')

require "rubygems"
require "merb-core"
require "spec"

require 'merb_resource_controller'

Merb.start :environment => 'test', :merb_root => File.join(File.dirname(__FILE__), 'integration')

Spec::Runner.configure do |config|
  config.include Merb::Test::RequestHelper
end