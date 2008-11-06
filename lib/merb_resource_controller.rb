# make sure we're running inside Merb
if defined?(Merb::Plugins)

  # Merb gave me a Merb::Plugins.config hash
  # i felt free to put my stuff in my piece of it
  Merb::Plugins.config[:merb_resource_controller] = {
    :identity_map => true
  }
  
  Merb::BootLoader.before_app_loads do
    # require code that must be loaded before the application
    DIR = File.join(File.dirname(__FILE__), 'merb_resource_controller')
    require DIR / 'resource_proxy'
    require DIR / 'actions'
    require DIR / 'resource_controller'
    if Merb::Plugins.config[:merb_resource_controller][:identity_map]
      require DIR / 'identity_map_support'
    end
  end
  
  Merb::BootLoader.after_app_loads do
    # code that can be required after the application loads
  end
  
end