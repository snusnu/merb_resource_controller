module Merb
  module ResourceController
    
    class ResourceProxy
  
      attr_reader :resource, :parents, :actions, :registered_methods
      
      def initialize(resource, options = {})
        @resource = load_resource(resource)
        @actions, @registered_methods, @parents = [], [], []
        @specific_methods_registered = options[:use] != :all
        register_default_actions! if options[:defaults]
        register_methods!(options[:use])
      end
      
      # ----------------------------------------------------------------------------------------
      # # one level nestings
      # ----------------------------------------------------------------------------------------
      # r.belongs_to :article               # assumes  :key => :article_id
      # r.belongs_to :article, :key => :foo # override :key => :foo
      # ----------------------------------------------------------------------------------------
      # # multi level nestings (array item ordering reflects nesting strategy)
      # ----------------------------------------------------------------------------------------
      # r.belongs_to [ :article, :post ]    # assumes  :key => :article_id and :key => :post_id 
      # r.belongs_to [ [ :article, :key => :foo ], :post ]
      # r.belongs_to [ [ :article, :key => :foo ], [ :post, :key => :bar ] ] ]
      # ----------------------------------------------------------------------------------------
      
      def belongs_to(parent, options = {})
        case parent
        when Symbol then
          options = { :key => Extlib::Inflection.foreign_key(parent) }.merge(options)
          @parents << { :name => parent, :class => load_resource(parent) }.merge(options)
        when Array  then
          parent.each do |p|
            case p
            when Symbol then
              options = { :key => Extlib::Inflection.foreign_key(p) }
              @parents << { :name => p, :class => load_resource(p) }.merge(options)
            when Array  then
              if p[0].is_a?(Symbol) && p[1].is_a?(Hash)
                @parents << { :name => p[0], :class => load_resource(p[0]) }.merge(p[1])
              else
                raise ArgumentError, "use [ Symbol, Hash ] to denote one of multiple parents"
              end
            else
              raise ArgumentError, "parent must be Symbol or Array but was #{p.class}"
            end
          end
        else
          raise ArgumentError, "parent must be Symbol or Array but was #{parent.class}"
        end
      end
      
      def belongs_to?(parent)
        @parents.any? { |h| h[:name] == parent }
      end
      
      
      def has_parents?
        !@parents.empty?
      end
      
      
      # all parent resources
      def parent_resources
        @parents.map { |h| h[:class] }
      end
      
      # the immediate parent resource
      def parent_resource
        has_parents? ? @parents.last[:class] : nil
      end
      
      
      # all parent resource keys
      def parent_keys
        @parents.map { |h| h[:key] }
      end
      
      # the immediate parent resource key
      def parent_key
        @parents.last[:key]
      end
      
  
      def action(name, options = {})
        options = { :to => name.to_sym, :scope => :collection }.merge(options)
        # raise_if_invalid_options!(options)
        @actions << { :name => name.to_sym }.merge(options)
      end
      
      
      def collection_name
        @resource.name.snake_case.pluralize
      end
      
      def member_name
        @resource.name.snake_case
      end
      
      
      def specific_methods_registered?
        @specific_methods_registered && !@registered_methods.empty?
      end
  
      def method_registered?(name)
        specific_methods_registered? ? registered_methods.map { |m| m[:name] }.include?(name.to_sym) : true
      end
      
      
      def method_missing(name, *args, &block)
        return super unless method_registered?(name)
        @resource.send(name, *args, &block)
      end
      
      
      private
      
      def load_resource(resource)
        Extlib::Inflection.constantize(Extlib::Inflection.classify(resource))
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
      
      
      # KEEP THESE for later
      
      def register_methods!(methods)
        @registered_methods = case methods
          when :all         then []
          when :web_methods then @resource.web_methods
          when Array        then methods
          else raise
        end
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