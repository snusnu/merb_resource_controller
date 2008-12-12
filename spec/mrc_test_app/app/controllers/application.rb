class Application < Merb::Controller
  include Merb::ResourceController::DM::IdentityMapSupport
  extend Merb::ResourceController::Mixin::ClassMethods
  extend Merb::ResourceController::ActionTimeout
  set_action_timeout 1
end