# Configure Rails Envinronment
ENV["RAILS_ENV"] = "test"

# only start SimpleCov on ruby 1.9.x
if RUBY_VERSION[0..2].to_f >= 1.9
  require 'simplecov'
  SimpleCov.start
end


require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require "rspec/rails"


ActionMailer::Base.delivery_method = :test
ActionMailer::Base.perform_deliveries = true
ActionMailer::Base.default_url_options[:host] = "test.com"

Rails.backtrace_cleaner.remove_silencers!

## Configure capybara for integration testing
#require "capybara/rails"
#Capybara.default_driver   = :rack_test
#Capybara.default_selector = :css

# Run any available migration
ActiveRecord::Migrator.migrate File.expand_path("../dummy/db/migrate/", __FILE__)

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  # Remove this line if you don't want RSpec's should and should_not
  # methods or matchers
  require 'rspec/expectations'
  config.include RSpec::Matchers

  # == Mock Framework
  config.mock_with :rspec
end
