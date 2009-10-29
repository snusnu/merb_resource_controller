# Go to http://wiki.merbivore.com/pages/init-rb

MERB_VERSION = '~> 1.1'
DM_VERSION   = '~> 0.10'

dependency "dm-core",        DM_VERSION
dependency "dm-validations", DM_VERSION
dependency "dm-serializer",  DM_VERSION
dependency "dm-constraints", DM_VERSION

dependency "merb-assets",    MERB_VERSION
dependency "merb-helpers",   MERB_VERSION

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
