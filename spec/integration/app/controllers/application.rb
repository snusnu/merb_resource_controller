class Application < Merb::Controller
  extend Merb::ResourceController::Mixin::ClassMethods
  extend Merb::ResourceController::DM::IdentityMapSupport
  enable_identity_map :action_timeout => 1
end