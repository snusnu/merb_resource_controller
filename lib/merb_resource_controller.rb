# make sure we're running inside Merb
if defined?(Merb::Plugins)

  # Merb gives you a Merb::Plugins.config hash...feel free to put your stuff in your piece of it
  Merb::Plugins.config[:merb_resource_controller] = {
    :orm => :datamapper
  }
  
  Merb::BootLoader.before_app_loads do
    # require code that must be loaded before the application
    DIR = File.join(File.dirname(__FILE__), 'merb_resource_controller')
    require DIR / 'resource_proxy'
    require DIR / 'actions'
    require DIR / 'resource_controller'
  end
  
  Merb::BootLoader.after_app_loads do
    # code that can be required after the application loads
  end
  
end