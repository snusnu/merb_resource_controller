module Merb
  module ResourceController
    module DM
      
      # include this into controllers
      module IdentityMapSupport
        
        # taken from:
        # http://datamapper.org/doku.php?id=docs:identity_map
        def _call_action(*)
          repository do |r| # enable identity_map
            Merb.logger.info "Using DM Identity map inside #{r.name} repository block"
            super
          end
        end
        
      end
    end
  end
end