# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{merb_resource_controller}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Martin Gamsjaeger"]
  s.date = %q{2008-11-05}
  s.description = %q{Merb plugin that provides the default restful actions for controllers.}
  s.email = %q{gamsnjaga@gmail.com}
  s.extra_rdoc_files = ["LICENSE", "TODO"]
  s.files = ["LICENSE", "README.textile", "Rakefile", "TODO", "lib/merb_resource_controller", "lib/merb_resource_controller/actions.rb", "lib/merb_resource_controller/resource_controller.rb", "lib/merb_resource_controller/resource_proxy.rb", "lib/merb_resource_controller.rb", "spec/article_comments_spec.rb", "spec/articles_spec.rb", "spec/comments_spec.rb", "spec/integration", "spec/integration/app", "spec/integration/app/controllers", "spec/integration/app/controllers/application.rb", "spec/integration/app/controllers/articles.rb", "spec/integration/app/controllers/comments.rb", "spec/integration/app/controllers/ratings.rb", "spec/integration/app/models", "spec/integration/app/models/article.rb", "spec/integration/app/models/comment.rb", "spec/integration/app/models/rating.rb", "spec/integration/app/views", "spec/integration/app/views/articles", "spec/integration/app/views/articles/edit.html.erb", "spec/integration/app/views/articles/index.html.erb", "spec/integration/app/views/articles/new.html.erb", "spec/integration/app/views/articles/show.html.erb", "spec/integration/app/views/comments", "spec/integration/app/views/comments/edit.html.erb", "spec/integration/app/views/comments/index.html.erb", "spec/integration/app/views/comments/new.html.erb", "spec/integration/app/views/comments/show.html.erb", "spec/integration/config", "spec/integration/config/database.yml", "spec/integration/config/dependencies.rb", "spec/integration/config/init.rb", "spec/integration/config/router.rb", "spec/integration/log", "spec/integration/log/merb.main.pid", "spec/integration/log/merb_test.log", "spec/merb_resource_controller_test.db", "spec/resource_proxy_spec.rb", "spec/spec.opts", "spec/spec_helper.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://merbivore.com/}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{merb}
  s.rubygems_version = %q{1.3.0}
  s.summary = %q{Merb plugin that provides the default restful actions for controllers.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<merb>, [">= 0.9.13"])
    else
      s.add_dependency(%q<merb>, [">= 0.9.13"])
    end
  else
    s.add_dependency(%q<merb>, [">= 0.9.13"])
  end
end
