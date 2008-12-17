# Go to http://wiki.merbivore.com/pages/init-rb

merb_gems_version = "~>1.0"
dm_gems_version   = "~>0.9.8"

dependency "dm-core",        dm_gems_version
dependency "dm-validations", dm_gems_version
dependency "dm-serializer",  dm_gems_version
dependency "dm-constraints", dm_gems_version

dependency "merb-assets",    merb_gems_version
dependency "merb-helpers",   merb_gems_version

use_orm :datamapper
use_test :rspec
use_template_engine :erb
 
Merb::Config.use do |c|
  c[:use_mutex] = false
  c[:session_store] = 'cookie'  # can also be 'memory', 'memcache', 'container', 'datamapper
  
  # cookie session store configuration
  c[:session_secret_key]  = 'snusnu'  # required for cookie session store
  # c[:session_id_key] = '_session_id' # cookie session id key, defaults to "_session_id"
end
 
Merb::BootLoader.before_app_loads do
  # This will get executed after dependencies have been loaded but before your app's classes have loaded.
  require Merb.root / '..' / '..' / 'lib' /'merb_resource_controller'
end
 
Merb::BootLoader.after_app_loads do
  # This will get executed after your app's classes have been loaded.
  DataMapper.auto_migrate!
end
