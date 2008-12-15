module Merb
  module ResourceController
    
    class ResourceControllerException < Exception; end
    class WebMethodsNotAvailable < ResourceControllerException; end
    class InvalidRoute < ResourceControllerException; end
    
    module Mixin
  
      module ClassMethods
        
        def controlling(name, options = {})
          @resource_proxy = Merb::ResourceController::ResourceProxy.new(name, options)
          yield @resource_proxy if block_given?
          class_inheritable_reader :resource_proxy
          include InstanceMethods
          @resource_proxy.registered_actions.each do |action|
            action_support = action_module(action[:name])
            include action_support
            include action_support.const_get("FlashSupport") if action[:flash]
            show_action(action[:name])
          end
        end
        
        def action_module(action)
          Merb::ResourceController::Actions.const_get(Extlib::Inflection.classify(action))
        end
    
      end
  
      module InstanceMethods
        
        protected
    
        def resource_proxy
          self.class.resource_proxy
        end
        
        
        def singleton_controller?
          resource_proxy.singleton_resource?
        end
        
        def has_parent?
          resource_proxy.has_parent? && has_parent_param?
        end
        
        def has_parent_param?
          !!parent_param
        end
        
        
        def parent
          resource_proxy.path_to_resource(params)[-2].last
        end
        
        # TODO refactor so that no additional queries are necessary
        def parents
          resource_proxy.parents.map do |parent|
            parent[:class].get(params[parent[:key]])
          end
        end
        
        def parent_param
          params[resource_proxy.parent_key]
        end
        
        
        def load_resource
          path = resource_proxy.path_to_resource(params)
          path.each do |pc|
            instance_variable_set("@#{pc[0]}", pc[1]) if pc[1]
          end
        end
        
        def requested_resource
          resource_proxy.path_to_resource(params).last.last
        end
        
         
        def set_collection(obj)
          instance_variable_set("@#{collection_name}", obj)
        end
        
        def set_member(obj)
          instance_variable_set("@#{member_name}", obj)
        end
        
        
        def collection_name(resource = nil)
          resource_proxy.collection_name(resource)
        end
        
        def member_name(resource = nil)
          resource_proxy.member_name(resource)
        end
        
        
        def collection
          instance_variable_get("@#{collection_name}")
        end
        
        def member
          instance_variable_get("@#{member_name}")
        end
        
        
        def new_member(attributes = {})
          resource_proxy.new_member(params, attributes)
        end
        
        def member_params(attributes = {})
          resource_proxy.member_params(params, attributes)
        end
        
        def parent_params
          resource_proxy.parent_params(params)
        end
        
        
        def flash_messages_for?(action)
          return false unless action_support = self.class.action_module(action)
          self.kind_of?(action_support.const_get("FlashSupport"))
        end
    
      end
  
    end
  
  end
end