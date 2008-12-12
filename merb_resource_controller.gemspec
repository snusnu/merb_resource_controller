# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{merb_resource_controller}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Martin Gamsjaeger"]
  s.date = %q{2008-12-10}
  s.description = %q{A merb plugin that provides the default restful actions for controllers.}
  s.email = %q{gamsnjaga@gmail.com}
  s.extra_rdoc_files = ["LICENSE", "TODO"]
  s.files = [
    'LICENSE',
    'README.textile',
    'Rakefile',
    'TODO',
    'lib/merb_resource_controller/action_timeout_support.rb',
    'lib/merb_resource_controller/actions.rb',
    'lib/merb_resource_controller/identity_map_support.rb',
    'lib/merb_resource_controller/resource_controller.rb',
    'lib/merb_resource_controller/resource_proxy.rb',
    'lib/merb_resource_controller.rb',
    'spec/mrc_test_app',
    'spec/mrc_test_app/Rakefile', 
    'spec/mrc_test_app/app/controllers/application.rb',
    'spec/mrc_test_app/app/controllers/articles.rb',
    'spec/mrc_test_app/app/controllers/community/comments.rb',
    'spec/mrc_test_app/app/controllers/community/ratings.rb',
    'spec/mrc_test_app/app/controllers/editors.rb',
    'spec/mrc_test_app/app/models/article.rb',
    'spec/mrc_test_app/app/models/comment.rb',
    'spec/mrc_test_app/app/models/editor.rb',
    'spec/mrc_test_app/app/models/rating.rb',
    'spec/mrc_test_app/config/database.yml',
    'spec/mrc_test_app/config/environments/development.rb',
    'spec/mrc_test_app/config/environments/rake.rb',
    'spec/mrc_test_app/config/environments/test.rb',
    'spec/mrc_test_app/config/init.rb',
    'spec/mrc_test_app/config/rack.rb',
    'spec/mrc_test_app/config/router.rb',
    'spec/mrc_test_app/app/views/articles/edit.html.erb',
    'spec/mrc_test_app/app/views/articles/index.html.erb',
    'spec/mrc_test_app/app/views/articles/new.html.erb',
    'spec/mrc_test_app/app/views/articles/show.html.erb',
    'spec/mrc_test_app/app/views/community/comments/edit.html.erb',
    'spec/mrc_test_app/app/views/community/comments/index.html.erb',
    'spec/mrc_test_app/app/views/community/comments/new.html.erb',
    'spec/mrc_test_app/app/views/community/comments/show.html.erb',
    'spec/mrc_test_app/app/views/community/ratings/edit.html.erb',
    'spec/mrc_test_app/app/views/community/ratings/index.html.erb',
    'spec/mrc_test_app/app/views/community/ratings/ne.html.erb',
    'spec/mrc_test_app/app/views/community/ratings/show.html.erb',
    'spec/mrc_test_app/app/views/editors/edit.html.erb',
    'spec/mrc_test_app/app/views/editors/new.html.erb',
    'spec/mrc_test_app/app/views/editors/show.html.erb',
    'spec/mrc_test_app/spec/lib/resource_proxy_spec.rb',
    'spec/mrc_test_app/spec/request/article_comment_rtings_spec.rb',
    'spec/mrc_test_app/spec/request/article_comments_spec.rb',
    'spec/mrc_test_app/spec/request/article_editor_spec.rb',
    'spec/mrc_test_app/spec/request/articles_spec.rb',
    'spec/mrc_test_app/spec/request/comments_spec.rb',
    'spec/mrc_test_app/spec/spec_helper.rb',
    'spec/mrc_test_app/spec/spec.opts'  
  ]
  s.homepage = %q{http://merbivore.com/}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{merb_resource_controller}
  s.rubygems_version = %q{1.3.0}
  s.summary = %q{A merb plugin that provides the default restful actions for controllers.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<merb-core>, ["~> 1.0"])
      s.add_development_dependency(%q<merb-assets>, ["~> 1.0"])
      s.add_development_dependency(%q<merb-helpers>, ["~> 1.0"])
      s.add_development_dependency(%q<dm-core>, ["~> 0.9.8"])
      s.add_development_dependency(%q<dm-validations>, ["~> 0.9.8"])
      s.add_development_dependency(%q<dm-serializer>, ["~> 0.9.8"])
      s.add_development_dependency(%q<dm-constraints>, ["~> 0.9.8"])
    else
      s.add_dependency(%q<merb-core>, ["~> 1.0"])
      s.add_dependency(%q<merb-assets>, ["~> 1.0"])
      s.add_dependency(%q<merb-helpers>, ["~> 1.0"])
      s.add_dependency(%q<dm-core>, ["~> 0.9.8"])
      s.add_dependency(%q<dm-validations>, ["~> 0.9.8"])
      s.add_dependency(%q<dm-serializer>, ["~> 0.9.8"])
      s.add_dependency(%q<dm-constraints>, ["~> 0.9.8"])
    end
  else
    s.add_dependency(%q<merb-core>, ["~> 1.0"])
    s.add_dependency(%q<merb-assets>, ["~> 1.0"])
    s.add_dependency(%q<merb-helpers>, ["~> 1.0"])
    s.add_dependency(%q<dm-core>, ["~> 0.9.8"])
    s.add_dependency(%q<dm-validations>, ["~> 0.9.8"])
    s.add_dependency(%q<dm-serializer>, ["~> 0.9.8"])
    s.add_dependency(%q<dm-constraints>, ["~> 0.9.8"])
  end
end
