module Merb
  module ResourceController
    
    class ResourceProxy
      
      attr_reader :resource, :parents, :actions, :registered_methods
      
      def initialize(resource, options = {})
        @resource, @singleton = load_resource(resource), !!options[:singleton]
        @actions, @registered_methods, @parents = [], [], []
        @specific_methods_registered = options[:use] != :all
        register_default_actions! if options[:defaults]
        register_methods!(options[:use])
      end
      
      def action(name, options = {})
        options = { :to => name.to_sym, :scope => :collection }.merge(options)
        # raise_if_invalid_options!(options)
        @actions << { :name => name.to_sym }.merge(options)
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
          options = { :key => Extlib::Inflection.foreign_key(parent), :singleton => false }.merge(options)
          @parents << { :name => parent, :class => load_resource(parent) }.merge(options)
        when Array  then
          parent.each do |p|
            case p
            when Symbol then
              options = { :key => Extlib::Inflection.foreign_key(p), :singleton => false }
              @parents << { :name => p, :class => load_resource(p) }.merge(options)
            when Array  then
              if p[0].is_a?(Symbol) && p[1].is_a?(Hash)
                options = { :key => Extlib::Inflection.foreign_key(p[0]), :singleton => false }.merge(p[1])
                @parents << { :name => p[0], :class => load_resource(p[0]) }.merge(options)
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
      
      def has_parent?
        !@parents.empty?
      end
      
      def has_parents?
        @parents.size > 1
      end
      
      
      def path_to_resource(params)
        nesting_strategy_instance(nesting_strategy_template(params)).map do |el|
          [ if el[2]
            el[0].name.snake_case.to_sym
          else
            el[1] ? el[0].name.snake_case.to_sym : Extlib::Inflection.tableize(el[0].name).to_sym
          end, el[3] ]
        end
      end

      def nesting_strategy_instance(nst, idx = 0)
        if nst[idx]
          if idx == 0
            if nst[idx][2]
              if nst[idx][1]
                raise "Toplevel singleton resources are not supported"
              else
                nst[idx] = nst[idx] + [ nst[idx][0].get(nst[idx][2]), nra(nst[idx][0], nst) ]
                nesting_strategy_instance(nst, idx + 1)
              end
            else
              nst[idx] = nst[idx] + [ nst[idx][0].all, nra(nst[idx][0], nst) ]
              nesting_strategy_instance(nst, idx + 1)
            end
          else
            if nst[idx][2]
              if nst[idx][1]
                nst[idx] = nst[idx] + [ nst[idx - 1][3].send(nst[idx - 1][4]), nra(nst[idx][0], nst) ]
                nesting_strategy_instance(nst, idx + 1)
              else
                nst[idx] = nst[idx] + [ nst[idx - 1][3].send(nst[idx - 1][4]).get(nst[idx][2]), nra(nst[idx][0], nst) ]
                nesting_strategy_instance(nst, idx + 1)
              end
            else
              nst[idx] = nst[idx] + [ nst[idx - 1][3].send(nst[idx - 1][4]), nra(nst[idx][0], nst) ]
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
          model, singleton, id = child[0], child[1], child[2]
          if id
            Extlib::Inflection.tableize(model.name).to_sym
          else
            singleton ? model.name.snake_case.to_sym : Extlib::Inflection.tableize(model.name).to_sym
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
        parent_params(params) << params["id"]
      end
      
      def nesting_strategy
        parent_resources << [ @resource, @singleton ]
      end
      
      def nesting_level
        nesting_strategy.size
      end
      
      
      # all parent parameters
      def parent_params(params)
        parent_keys.map { |k| params[k] }
      end
      
      # the immediate parent parameter    
      def parent_param(params)
        parent_params(params).last
      end
      
      
      # all parent resources
      def parent_resources
        @parents.map { |h| [ h[:class], h[:singleton] ] }
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
      
      
      def collection_name(resource = nil)
        (resource || @resource).name.snake_case.pluralize
      end
      
      def member_name(resource = nil)
        (resource || @resource).name.snake_case
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
        [ :index, :show, :new, :edit, :create, :update, :destroy ].each do |a|
          action(a)
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