module Merb
  module ResourceController
    module DM
      
      # to be extended into controller
      module IdentityMapSupport
        
        def enable_identity_map(options = {})
          @action_timeout = options[:action_timeout] || 0
          # maybe also useful for retries
          class_inheritable_accessor :action_timeout
          include InstanceMethods
        end
        
        module InstanceMethods
        
          # taken from:
          # http://datamapper.org/doku.php?id=docs:identity_map
          def _call_action(*)
            repository do |r| # enable identity_map
              Merb.logger.info "Inside #{r.name} repository block"
              if self.class.respond_to?(:action_timeout)
                return super if self.class.action_timeout < 1
                # more information on system_timer:
                # http://adam.blog.heroku.com/past/2008/6/17/battling_wedged_mongrels_with_a/
                require 'system_timer' # laziness
                SystemTimer.timeout(self.class.action_timeout) do
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
  end
end