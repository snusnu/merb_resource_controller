module Merb
  module ResourceController
    
    
    FLASH_SUPPORT_MODULE = "FlashSupport"

    def self.action_module(action)
      Actions.const_get(Extlib::Inflection.classify(action))
    end
    
    
    class ActionDescriptor
      
      SUPPORTED_SCENARIOS     = [ :success, :failure ]
      FORMAT_RESTRICTION_APIS = [ :provides, :only_provides, :does_not_provide ]
    
      attr_reader :action_name, :provided_formats, :options
      
      def initialize(name, provided_formats, options = {})
        raise unless valid_format_restriction?(options)
        @action_name, @provided_formats, @options = name.to_sym, provided_formats, options
        @content_type_handlers = { :success => {}, :failure => {} }
        handle_default_content_types if options[:default_formats]
      end
      
      
      def action_module
        Merb::ResourceController.action_module(@action_name)
      end
      
      
      def supports_flash_messages?
        !!@options[:flash] && has_flash_module?
      end
      
      def has_flash_module?
        !flash_module.nil?
      end
      
      def flash_module
        action_module.const_get Merb::ResourceController::FLASH_SUPPORT_MODULE
      rescue
        nil
      end
      
      
      def handle_default_content_types
        handle
      end
      
      def handle(format = nil, scenario = nil)
        raise "#{scenario} is not supported" unless SUPPORTED_SCENARIOS.include?(scenario) || scenario.nil?
        (format ? format.is_a?(Array) ? format : [ format ] : @provided_formats).each do |f|
          (scenario ? [ scenario ] : SUPPORTED_SCENARIOS).each do |s| 
            @content_type_handlers[s][f] = content_type_handler_method(f, s)
          end
        end
      end
      
      def content_type_handler(format, scenario)
        @content_type_handlers[scenario.to_sym][format.to_sym]
      end
      
      def content_type_handler_method(format, scenario)
        case scenario
        when :success then "#{format}_response_on_successful_#{@action_name}"
        when :failure then "#{format}_response_on_failed_#{@action_name}"
        else
          raise "default_content_type_handler doesn't support #{scenario.inspect} (only :on_success and :on_failure)"
        end
      end
      
      
      def valid_format_restriction?(options = nil)
        format_restriction(options || @options).size <= 1 # empty is valid too
      end
      
      def has_format_restriction?(options = nil)
        format_restriction(options).size > 0
      end
      
      def format_restrictor_method(options = nil)
        o = options || @options
        lambda { send(format_restriction_api(o), restricted_formats(o)) }
      end
      
      
      def format_restriction_api(options = nil)
        format_restriction(options || @options).map { |kv| kv[0] }.first
      end
      
      def restricted_formats(options = nil)
        format_restriction(options || @options).map { |kv| kv[1] }.flatten
      end
      
      def format_restriction(options = nil)
        (options || @options).select { |k,v| format_restriction_apis.include?(k) }
      end
      
      def format_restriction_apis
        FORMAT_RESTRICTION_APIS
      end
  
    end
  
  end
end