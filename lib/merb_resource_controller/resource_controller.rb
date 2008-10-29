module Merb
  module ResourceController
    
    class ResourceControllerException < Exception; end
    class WebMethodsNotAvailable < ResourceControllerException; end
    class InvalidRoute < ResourceControllerException; end
    
    module Mixin
  
      module ClassMethods
    
        # DEFAULTS to the following if no block is given
        # ----------------------------------------------
        # controlling :projects do |p|
        #   p.action :index,   :provides => [ :json, :yaml ], :on => :collection,
        #   p.action :show
        #   p.action :new,     :provides => :html
        #   p.action :edit,    :provides => :html
        #   p.action :create  
        #   p.action :update
        #   p.action :destroy
        # end
        def controlling(name, options = {})
          options = { :defaults => true, :flash => true }.merge!(options)
          @resource_proxy = Merb::ResourceController::ResourceProxy.new(name, options)
          yield @resource_proxy if block_given?
          class_inheritable_reader :resource_proxy
          include InstanceMethods
          include FlashSupport if options[:flash]
          @resource_proxy.actions.each do |a|
            include Merb::ResourceController::Actions.const_get("#{a[:name].to_s.camel_case}")
            show_action(a[:name])
          end
        end
    
      end
  
      module InstanceMethods
        
        protected
    
        def resource_proxy
          puts "XXXXXXXXXXX"
          puts "XXXXXXXXXXX"
          puts "XXXXXXXXXXX"
          puts "XXXXXXXXXXX"
          self.class.resource_proxy
        end
        
        
        def load_collection
          resource_proxy.all
        end
        
        def load_member(id)
          resource_proxy.get(id)
        end
        
        
        def collection=(obj)
          instance_variable_set("@#{collection_name}", obj)
        end
        
        def collection
          instance_variable_get("@#{collection_name}")
        end
        
        
        def new_member(attributes = {})
          resource_proxy.new(attributes)
        end
        
        def member=(obj)
          instance_variable_set("@#{member_name}", obj)
        end
        
        def member
          instance_variable_get("@#{member_name}")
        end
        
        
        def collection_name
          resource_proxy.collection_name
        end
        
        def member_name
          resource_proxy.member_name
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