require 'system_timer'

module Merb
  module ResourceController
      
    # To be extended into controllers
    module ActionTimeout
      
      def self.for?(controller)
        self.for(controller) > 0
      end
      
      def self.for(controller)
        (@controllers ||= {})[Application] || @controllers[controller] || 0
      end
      
      def self.register(controller, seconds)
        (@controllers ||= {})[controller] = seconds
      end
      
      
      def set_action_timeout(seconds)
        if seconds >= 1
          ActionTimeout.register(self, seconds)
          include InstanceMethods
        end
      end
      
      module InstanceMethods
        
        # taken from:
        # http://datamapper.org/doku.php?id=docs:identity_map
        def _call_action(*args)
          if Merb::Plugins.config[:merb_resource_controller][:action_timeout]
            return super unless ActionTimeout.for?(self.class)
            timeout = ActionTimeout.for(self.class)
            Merb.logger.info "SystemTimer.timeout for #{args[0]}: #{timeout} seconds"
            # more information on system_timer:
            # http://adam.blog.heroku.com/past/2008/6/17/battling_wedged_mongrels_with_a/
            SystemTimer.timeout(timeout) do
              super
            end
          else
            super
          end
        end
        
      end
      
    end
      
  end
end