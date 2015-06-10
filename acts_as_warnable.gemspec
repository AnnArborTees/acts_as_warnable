$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "acts_as_warnable/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "acts_as_warnable"
  s.version     = ActsAsWarnable::VERSION
  s.authors     = ["Nigel Baillie"]
  s.email       = ["metreckk@gmail.com"]
  # s.homepage    = "TODO"
  s.summary     = "Allows models to issue warnings if a task goes wrong"
  s.description = "Allows models to issue warnings if a task goes wrong"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.2.1"
  s.add_dependency "devise"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency 'rspec-rails', '~> 3.0'
  s.add_development_dependency 'factory_girl_rails', '>= 4.2.0'
  s.add_development_dependency 'shoulda-matchers'
end
