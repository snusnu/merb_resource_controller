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
          options = { :defaults => true, :flash => true, :use => :all }.merge!(options)
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
          self.class.resource_proxy
        end
        
        
        def irrelevant_params
          @irrelevant_params ||= %w(format action controller)
        end
        
        def relevant_params
          @relevant_params ||= params.reject { |k,v| irrelevant_params.include?(k) }
        end
        
        
        def has_parents?
          resource_proxy.has_parents? && has_parent_param?
        end
        
        alias :has_parent? :has_parents?
        
        
        def parent_resources
          resource_proxy.parent_resources
        end
        
        def parent_resource
          resource_proxy.parent_resource
        end
        
        
        def parents
          resource_proxy.parents.each do |parent|
            parent[:class].get(params[parent[:key]])
          end
        end
        
        def parent
          parent_resource.get(parent_param)
        end
        
        
        def has_parent_param?
          !!parent_param
        end
        
        alias :has_parent_params? :has_parent_param?
        
        
        def parent_params
          resource_proxy.parent_keys.inject([]) do |parents, key|
            parents << params[key]
          end
        end
                
        def parent_param
          params[resource_proxy.parent_key]
        end
        
        
        def load_collection(conditions = {})
          resource_proxy.all(query_conditions(conditions))
        end
        
        def load_member(id, conditions = {})
          resource_proxy.get(id, query_conditions(conditions))
        end
        
        
        def set_collection(obj)
          instance_variable_set("@#{collection_name}", obj)
        end
        
        def collection
          instance_variable_get("@#{collection_name}")
        end
        
        
        def new_member(attributes = {})
          resource_proxy.new(attributes)
        end
        
        def set_member(obj)
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
        
        # TODO: try to get dm bug shown in http://gist.github.com/22146 fixed
        # once it is fixed, we can only return the real conditions, and not the
        # whole hash including the :conditions key, which will simplify logic
        # inside this method.
        def query_conditions(conditions = {})
          if conditions.empty?
            relevant_params.empty? ? {} : { :conditions => relevant_params }
          else
            conditions
          end
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