$:.push File.join(File.dirname(__FILE__), '..', 'lib')

require "rubygems"

# Add the local gems dir if found within the app root; any dependencies loaded
# hereafter will try to load from the local gems before loading system gems.
if (local_gem_dir = File.join(File.dirname(__FILE__), '..', 'gems')) && $BUNDLE.nil?
  $BUNDLE = true; Gem.clear_paths; Gem.path.unshift(local_gem_dir)
end

require "merb-core"
require "spec" # Satisfies Autotest and anyone else not using the Rake tasks

# this loads all plugins required in your init file so don't add them
# here again, Merb will do it for you
Merb.start_environment(
  :merb_root => File.join(File.dirname(__FILE__), '..'),
  :environment => 'test'
)

Spec::Runner.configure do |config|
  config.include Merb::Test::RequestHelper
  config.include(Merb::Test::ControllerHelper)
  config.include(Merb::Test::ViewHelper)
  config.include(Merb::Test::RouteHelper)
end

# -----------------------------------------------------------------------------------------------
# -----------------------------------------------------------------------------------------------

given "an Article exists" do
  DataMapper.auto_migrate!
  request(
    resource(:articles), 
    :method => "POST", 
    :params => { 
      :article => { 
        :id => nil, 
        :title => "article title", 
        :body => "article body" 
      }
    }
  )
end

given "an Editor exists" do
  DataMapper.auto_migrate!
  Editor.create({ :id => nil, :name => "snusnu" })
  request(
    resource(:articles), 
    :method => "POST", 
    :params => { 
      :article => { 
        :id => nil, 
        :editor_id => Editor.first.id, 
        :title => "article title", 
        :body => "article body" 
      }
    }
  )
end

given "a Comment exists" do
  DataMapper.auto_migrate!
  request(
    resource(:articles), 
    :method => "POST", 
    :params => { 
      :article => { 
        :id => nil, 
        :title => "article title", 
        :body => "article body" 
      }
    }
  )
  request(
    resource(:comments), 
    :method => "POST", 
    :params => { 
      :comment => { 
        :id => nil,
        :article_id => Article.first.id,
        :body => "comment body" 
      }
    }
  )
end

given "a Rating exists" do
  DataMapper.auto_migrate!
  request(
    resource(:articles), 
    :method => "POST", 
    :params => { 
      :article => { 
        :id => nil, 
        :title => "article title", 
        :body => "article body"
      }
    }
  )
  request(
    resource(Article.first, :comments), 
    :method => "POST", 
    :params => { 
      :comment => { 
        :id => nil, 
        :body => "comment body" 
      }
    }
  )
  request(
    resource(Article.first, Community::Comment.first, :ratings), 
    :method => "POST", 
    :params => { 
      :rating => { 
        :id => nil, 
        :rate => 1 
      }
    }
  )
end

given "3 Ratings exist" do
  DataMapper.auto_migrate!
  request(
    resource(:articles), 
    :method => "POST", 
    :params => { 
      :article => { 
        :title => "article title", 
        :body => "article body"
      }
    }
  )
  2.times do
    request(
      resource(Article.first, :comments), 
      :method => "POST", 
      :params => { 
        :comment => {
          :body => "comment body" 
        }
      }
    )
  end
  2.times do
    request(
      resource(Article.first, Community::Comment.first, :ratings), 
      :method => "POST", 
      :params => { 
        :rating => {
          :rate => 1 
        }
      }
    )
  end
  request(
    resource(Article.first, Community::Comment.all.last, :ratings), 
    :method => "POST", 
    :params => { 
      :rating => {
        :rate => 1 
      }
    }
  )
end

given "2 articles and 3 comments exist" do
  DataMapper.auto_migrate!
  2.times do
    request(
      resource(:articles), 
      :method => "POST", 
      :params => { 
        :article => { 
          :id => nil, 
          :title => "article title", 
          :body => "article body" 
        }
      }
    )
  end
  2.times do
    request(
      resource(Article.first, :comments), 
      :method => "POST", 
      :params => { 
        :comment => { 
          :id => nil, 
          :body => "comment body"
        }
      }
    )
  end
  request(
    resource(Article.all.last, :comments), 
    :method => "POST", 
    :params => { 
      :comment => { 
        :id => nil, 
        :body => "comment body" 
      }
    }
  )
end