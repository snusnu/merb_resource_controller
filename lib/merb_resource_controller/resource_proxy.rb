module Merb
  module ResourceController
    
    class ResourceProxy
  
      attr_reader :resource, :actions, :registered_methods
      
      def initialize(resource, options = {})
        @resource, @actions, @registered_methods = load_resource(resource), [], []
        register_default_actions! if options[:defaults]
        register_methods!(options[:use] || :all)
      end
  
      def action(name, options = {})
        options = { :to => name.to_sym, :scope => :collection }.merge(options)
        # raise_if_invalid_options!(options)
        @actions << { :name => name.to_sym }.merge(options)
      end
      
      def method_missing(name, *args, &block)
        return super unless method_registered?(name)
        @resource.send(name, *args, &block)
      end
      
      
      def methods_registered?
        !@registered_methods.empty?
      end
  
      def method_registered?(name)
        methods_registered? ? registered_methods.map { |m| m[:name] }.include?(name.to_sym) : true
      end
      
      
      def collection_name
        @resource.name.snake_case.pluralize
      end
      
      def member_name
        @resource.name.snake_case
      end
      
      
      private
      
      def load_resource(resource)
        Extlib::Inflection.constantize(Extlib::Inflection.classify(resource))
      end
  
      def register_methods!(methods)
        @registered_methods = case methods
          when :all         then []
          when :web_methods then @resource.web_methods
          when Array        then methods
          else raise
        end
      end
      
      def register_default_actions!
        action :index,  :provides => [ :json, :yaml ]
        action :show
        action :new,    :provides => :html
        action :edit,   :provides => :html
        action :create  
        action :update
        action :destroy
      end
      
      def raise_if_invalid_options!(options)
        if options[:use] == :web_methods && !@resource.respond_to?(:web_methods)
          raise WebMethodsNotAvailable, "require 'dm-is-online' if you want to use web_methods"
        end
        meth = options[:to]        
        if options[:use] == :all
          msg = "merb_resource_controller: #{@resource}.public_methods.include?(:#{meth}) == false"
          raise InvalidRoute, msg unless @resource.public_methods.include?(meth)
        elsif options[:use] == :web_methods
          msg = "merb_resource_controller: #{@resource}.web_methods.include?(:#{meth}) == false"
          raise InvalidRoute, msg unless @resource.web_methods.include?(meth)
        else
          msg = "merb_resource_controller: Invalid option[:use] = #{options[:use]}, using :all instead"
          Merb::Logger.warn(msg)
        end
      end
  
    end
  
  end
end