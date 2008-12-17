module Merb
  module ResourceController
    
    class ResourceProxy
      
      DEFAULT_NESTING_OPTIONS = {
        :singleton => false, 
        :fully_qualified => false
      }
            
      DEFAULT_OPTIONS = DEFAULT_NESTING_OPTIONS.merge({
        :defaults => true,
        :use => :all
      })
      
      attr_reader :resource, :provided_formats, :parents, :registered_methods
      
      def initialize(resource, provided_formats, options = {})
        options = DEFAULT_OPTIONS.merge(options)
        @resource, @singleton = load_resource(resource), !!options[:singleton]
        @provided_formats = provided_formats || [ :html ]
        @fully_qualified = !!options[:fully_qualified]
        @actions, @registered_methods, @parents = [], [], []
        @specific_methods_registered = options[:use] != :all
        register_default_actions! if options[:defaults]
        register_methods!(options[:use])
      end
      
      def action(name, options = {})
        options = { :default_formats => true }.merge(options)
        descriptor = ActionDescriptor.new(name, @provided_formats, options)
        yield descriptor if block_given?
        @actions << descriptor
      end
            
      def actions(*action_specs)
        action_specs.each { |a| a.is_a?(Hash) ? action(a.delete(:name), a) : action(a) }
      end
      
      def registered_actions
        @actions
      end
      
      def flash_messages_for?(action)
        return false unless @actions.map { |ad| ad.action_name }.include?(action.to_sym)
        @actions.any? { |ad| ad.action_name == action.to_sym && ad.supports_flash_messages? }
      end
      
      
      def action_descriptor(action)
        ad = @actions.select { |ad| ad.action_name == action.to_sym }
        ad.first ? ad.first : raise("No action named #{action} is registered for this controller")
      end
      
      def content_type_handler(action, format, scenario)
        action_descriptor(action).content_type_handler(format, scenario)
      end
      
      def has_format_restriction?(action)
        action_descriptor(action).has_format_restriction?
      end
      
      def action_specific_provides(action)
        ad = action_descriptor(action)
        [ ad.format_restriction_api, ad.restricted_formats ]
      end
      
      def register_default_actions!
        action :index    unless @singleton
        action :show
        action :new,     :only_provides => :html
        action :edit,    :only_provides => :html
        action :create,  :flash => true
        action :update,  :flash => true
        action :destroy, :flash => true
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
        when Symbol, String then
          options = DEFAULT_NESTING_OPTIONS.merge(:key => key_name(parent)).merge(options)
          @parents << { :name => parent, :class => load_resource(parent) }.merge(options)
        when Array  then
          parent.each do |p|
            case p
            when Symbol, String then
              options = DEFAULT_NESTING_OPTIONS.merge(:key => key_name(p))
              @parents << { :name => p, :class => load_resource(p) }.merge(options)
            when Array  then
              if (p[0].is_a?(Symbol) || p[0].is_a?(String)) && p[1].is_a?(Hash)
                options = DEFAULT_NESTING_OPTIONS.merge(:key => key_name(p[0])).merge(p[1])
                @parents << { :name => p[0], :class => load_resource(p[0]) }.merge(options)
              else
                raise ArgumentError, "use [ Symbol|String, Hash ] to denote one of multiple parents"
              end
            else
              raise ArgumentError, "parent must be Symbol, String or Array but was #{p.class}"
            end
          end
        else
          raise ArgumentError, "parent must be Symbol, String or Array but was #{parent.class}"
        end
      end
      
      def belongs_to?(parent)
        @parents.any? { |h| h[:name] == parent }
      end
      
      def has_parent?
        !@parents.empty?
      end
      
      def has_parents?
        @parents.size > 1
      end
      
      def fully_qualified?
        @fully_qualified
      end
      
      def singleton_resource?
        @singleton
      end
      
      
      def path_to_resource(params)
        nesting_strategy_instance(nesting_strategy_template(params)).map do |i|
          [ i[3] ? member_name(i[0], i[2]) : i[1] ? member_name(i[0], i[2]) : collection_name(i[0], i[2]), i[4] ]
        end
      end

      def nesting_strategy_instance(nst, idx = 0)
        if nst[idx]
          if idx == 0
            if nst[idx][3]
              if nst[idx][1]
                raise "Toplevel singleton resources are not supported"
              else
                nst[idx] = nst[idx] + [ nst[idx][0].get(nst[idx][3]), nra(nst[idx][0], nst) ]
                nesting_strategy_instance(nst, idx + 1)
              end
            else
              nst[idx] = nst[idx] + [ nst[idx][0].all, nra(nst[idx][0], nst) ]
              nesting_strategy_instance(nst, idx + 1)
            end
          else
            if nst[idx][3]
              if nst[idx][1]
                nst[idx] = nst[idx] + [ nst[idx - 1][4].send(nst[idx - 1][5]), nra(nst[idx][0], nst) ]
                nesting_strategy_instance(nst, idx + 1)
              else
                nst[idx] = nst[idx] + [ nst[idx - 1][4].send(nst[idx - 1][5]).get(nst[idx][3]), nra(nst[idx][0], nst) ]
                nesting_strategy_instance(nst, idx + 1)
              end
            else
              nst[idx] = nst[idx] + [ nst[idx - 1][4].send(nst[idx - 1][5]), nra(nst[idx][0], nst) ]
              nesting_strategy_instance(nst, idx + 1)
            end
          end
        else
          nst
        end
      end

      # nested_resource_accessor
      def nra(member, nst)
        member = member.is_a?(Class) ? member : member.class
        return nil unless idx = nst.map { |el| el[0] }.index(member)
        if child = nst[idx + 1]
          model, singleton, fully_qualified, id = child[0], child[1], child[2], child[3]
          if id
            collection_name(model, fully_qualified)
          else
            singleton ? member_name(model, fully_qualified) : collection_name(model, fully_qualified)
          end
        else
          nil
        end
      end
      
      
      def nesting_strategy_template(params)
        idx = -1
        nesting_strategy_params(params).map do |nsp|
          nesting_strategy[idx += 1] << nsp
        end
      end
      
      def nesting_strategy_params(params)
        parent_param_values(params) << params["id"]
      end
      
      def nesting_strategy
        parent_resources << [ @resource, @singleton, fully_qualified? ]
      end
      
      def nesting_level
        nesting_strategy.size
      end
      
      
      # all parent parameters
      def parent_param_values(params)
        parent_keys.map { |k| params[k] }
      end
      
      # the immediate parent parameter    
      def parent_param_value(params)
        parent_param_values(params).last
      end
      
      
      def new_member(params, attributes = {})
        resource.new(member_params(params, attributes))
      end
      
      def member_params(params, attributes = {})
        if attrs = params[member_name]
          has_parent? ? parent_params(params).merge!(attrs).merge!(attributes) : attrs.merge!(attributes)
        else
          has_parent? ? parent_params(params).merge!(attributes) : attributes
        end
      end
      
      def parent_params(params)
        parent_keys.inject({}) do |hash, key|
          key = key.to_sym
          hash[key] = params[key] if resource.properties.map { |p| p.name }.include?(key.to_sym)
          hash
        end
      end
      
      
      # all parent resources
      def parent_resources
        @parents.map { |h| [ h[:class], h[:singleton], h[:fully_qualified] ] }
      end
      
      # the immediate parent resource
      def parent_resource
        parent_resources.last
      end
      
      
      # all parent resource keys
      def parent_keys
        @parents.map { |h| h[:key] }
      end
      
      # the immediate parent resource key
      def parent_key
        @parents.last ? @parents.last[:key] : nil
      end
      
      
      def collection_name(resource = nil, fully_qualified = false)
        if fully_qualified
          Extlib::Inflection.tableize((resource || @resource).name).to_sym
        else  
          Extlib::Inflection.demodulize((resource || @resource).name).pluralize.snake_case.to_sym
        end
      end
      
      def member_name(resource = nil, fully_qualified = false)
        collection_name(resource, fully_qualified).to_s.singularize.to_sym
      end
      
      def key_name(resource = nil)
        Extlib::Inflection.foreign_key(resource || @resource)
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
      
      def load_resource(r)
        case r
        when Symbol
          Module.find_const(r.to_s.singular.camel_case)
        when String
          Module.find_const(r.include?('::') ? r : r.singular.camel_case)
        when Class
          r
        else
          raise "resource must be either a Symbol, a String or a Class"
        end
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
      
      # def raise_if_invalid_options!(options)
      #   if options[:use] == :web_methods && !@resource.respond_to?(:web_methods)
      #     raise WebMethodsNotAvailable, "require 'dm-is-online' if you want to use web_methods"
      #   end
      #   meth = options[:to]        
      #   if options[:use] == :all
      #     msg = "merb_resource_controller: #{@resource}.public_methods.include?(:#{meth}) == false"
      #     raise InvalidRoute, msg unless @resource.public_methods.include?(meth)
      #   elsif options[:use] == :web_methods
      #     msg = "merb_resource_controller: #{@resource}.web_methods.include?(:#{meth}) == false"
      #     raise InvalidRoute, msg unless @resource.web_methods.include?(meth)
      #   else
      #     msg = "merb_resource_controller: Invalid option[:use] = #{options[:use]}, using :all instead"
      #     Merb::Logger.warn(msg)
      #   end
      # end
  
    end
  
  end
end