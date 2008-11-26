# make sure we're running inside Merb
if defined?(Merb::Plugins)

  # Merb gave me a Merb::Plugins.config hash
  # i felt free to put my stuff in my piece of it
  Merb::Plugins.config[:merb_resource_controller] = {
    :identity_map => true,
    :action_timeout => true
  }
  
  Merb::BootLoader.before_app_loads do
    # require code that must be loaded before the application
    MRC = File.join(File.dirname(__FILE__), 'merb_resource_controller')
    require MRC / 'resource_proxy'
    require MRC / 'actions'
    require MRC / 'resource_controller'
    if Merb::Plugins.config[:merb_resource_controller][:identity_map]
      require MRC / 'identity_map_support'
    end
    if Merb::Plugins.config[:merb_resource_controller][:action_timeout]
      require MRC / 'action_timeout_support'
    end
  end
  
  Merb::BootLoader.after_app_loads do
    # code that can be required after the application loads
  end
  
end