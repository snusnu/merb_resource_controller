module Merb
  module ResourceController
    
    class ResourceControllerException < Exception; end
    class WebMethodsNotAvailable < ResourceControllerException; end
    class InvalidRoute < ResourceControllerException; end
    
    module Mixin
  
      module ClassMethods
        
        def controlling(name, options = {})
          options = { 
            :defaults => true, 
            :flash => true, 
            :use => :all, 
            :fully_qualified => false 
          }.merge!(options)
          @resource_proxy = Merb::ResourceController::ResourceProxy.new(name, options)
          yield @resource_proxy if block_given?
          class_inheritable_reader :resource_proxy
          include InstanceMethods
          include FlashSupport if options[:flash]
          @resource_proxy.registered_actions.each do |a|
            include Merb::ResourceController::Actions.const_get("#{a[:name].to_s.camel_case}")
            show_action(a[:name])
          end
        end
    
      end
  
      module InstanceMethods
        
        protected
    
        def resource_proxy
          self.class.resource_proxy
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
        
        def parents
          resource_proxy.parents.map do |parent|
            parent[:class].get(params[parent[:key]])
          end
        end
        
        def parent_param
          params[resource_proxy.parent_key]
        end
        
        
        def load_resource
          resource_proxy.path_to_resource(params).each do |pc|
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
        
        
        def collection
          instance_variable_get("@#{collection_name}")
        end
        
        def member
          instance_variable_get("@#{member_name}")
        end
        
        def new_member(attributes = {})
          resource_proxy.new(attributes)
        end
        
        
        def collection_name(resource = nil)
          resource_proxy.collection_name(resource)
        end
        
        def member_name(resource = nil)
          resource_proxy.member_name(resource)
        end
        
        
        def flash_supported?
          self.kind_of?(FlashSupport)
        end
    
      end
      
      module FlashSupport
        
        protected
        
        def successful_create_messages
          { :notice => "#{member.class.name} was successfully created" }
        end
                
        def failed_create_messages
          { :error => "Failed to create new #{member.class.name}" }
        end
        
                
        def successful_update_messages
          { :notice => "#{member.class.name} was successfully updated" }
        end
                
        def failed_update_messages
          { :error => "Failed to update #{member.class.name}" }
        end
                
                
        def successful_destroy_messages
          { :notice => "#{member.class.name} was successfully destroyed" }
        end
                
        def failed_destroy_messages
          { :error => "Failed to destroy #{member.class.name}" }
        end
        
      end
  
    end
  
  end
end