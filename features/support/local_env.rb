require 'rubygems'

ENV['RAILS_ENV'] ||= 'test'

require 'simplecov'
SimpleCov.start 'rails' do
  add_filter '/bin/'
  add_filter '/db/'
  add_filter '/spec/' # for rspec
  add_filter '/test/' # for minitest
end

require 'cucumber/rails'
require 'capybara/rails'
require 'email_spec/cucumber'
require 'capybara/cucumber'

# Configure Capybara/Selenium
require "selenium/webdriver"
require 'webdrivers/chromedriver'

Capybara.javascript_driver = :headless_chrome
Webdrivers.logger.level = :DEBUG
Webdrivers::Chromedriver.required_version = '75.0.3770.140'
Selenium::WebDriver::Chrome.path = '/usr/bin/google-chrome'

Capybara.register_driver :chrome do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome)
end

Capybara.register_driver :headless_chrome do |app|
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
      chromeOptions: { args: %w(headless single-process no-gpu no-sandbox disable-setuid-sandbox disable-dev-shm-usage) } # disable-gpu proxy-server="direct://" proxy-bypass-list="*"
  )

  Capybara::Selenium::Driver.new app,
                                 browser: :chrome,
                                 desired_capabilities: capabilities
end

Capybara.default_selector = :css
Capybara.exact= true
Capybara.configure do |config|
  config.match = :prefer_exact
end
#Selenium::WebDriver::Firefox::Binary.path='/home/derrell/INSTALLS/firefox/firefox'
ActionController::Base.allow_rescue = false
Cucumber::Rails::Database.javascript_strategy = :truncation

require 'rspec/rails'
Capybara.default_max_wait_time = 15
RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.use_transactional_examples = false
end

Before('@javascript') do # @no-txn,@selenium,@culerity,@celerity,
  # { :except => [:widgets] } may not do what you expect here
  # as Cucumber::Rails::Database.javascript_strategy overrides
  # this setting.
  # DatabaseCleaner.strategy = :truncation
  Capybara.default_max_wait_time = 30
  RSpec.configure do |config|
    config.use_transactional_fixtures = true
    config.use_transactional_examples = false
  end
end

class ActiveRecord::Base
  mattr_accessor :shared_connection
  @@shared_connection = nil

  def self.connection
    @@shared_connection || retrieve_connection
  end
end

# Forces all threads to share the same connection. This works on
# Capybara because it starts the web server in a thread.
ActiveRecord::Base.shared_connection = ActiveRecord::Base.connection

require 'rack/utils'
Capybara.app = Rack::ShowExceptions.new(AliasMadness::Application)


require 'json'
module JSON
  class << self
    def parse(source, opts = {})
      opts = ({:max_nesting => false}).merge(opts)
      Parser.new(source, opts).parse
    end
  end
end

# require 'selenium-webdriver'
# require 'chromedriver-helper'
# Capybara.register_driver :chrome do |app|
#   Capybara::Selenium::Driver.new(app, browser: :chrome)
# end

# Capybara.register_driver :headless_chrome do |app|
#   capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
#       chromeOptions: { args: %w(headless disable-gpu) }
#   )
#
#   Capybara::Selenium::Driver.new app,
#                                  browser: :chrome,
#                                  desired_capabilities: capabilities
# end
#
# Capybara.javascript_driver = :headless_chrome
# chosen_capybara_driver = :chrome # :culerity # :webkit # :poltergeist
# Capybara.javascript_driver = chosen_capybara_driver
#
#
# # Possible values are :truncation and :transaction
# # The :transaction strategy is faster, but might give you threading problems.
# # See https://github.com/cucumber/cucumber-rails/blob/master/features/choose_javascript_database_strategy.feature
# Cucumber::Rails::Database.javascript_strategy = :truncation
#
# require 'rspec/rails'
# Capybara.default_max_wait_time = 15
# RSpec.configure do |config|
#   config.use_transactional_fixtures = true
#   config.use_transactional_examples = false
# end
#
# Before('@javascript') do # @no-txn,@selenium,@culerity,@celerity,
#   # { :except => [:widgets] } may not do what you expect here
#   # as Cucumber::Rails::Database.javascript_strategy overrides
#   # this setting.
#   # DatabaseCleaner.strategy = :truncation
#   Capybara.default_max_wait_time = 30
#   RSpec.configure do |config|
#     config.use_transactional_fixtures = true
#     config.use_transactional_examples = false
#   end
# end
#
# class ActiveRecord::Base
#   mattr_accessor :shared_connection
#   @@shared_connection = nil
#
#   def self.connection
#     @@shared_connection || retrieve_connection
#   end
# end
#
# # Forces all threads to share the same connection. This works on
# # Capybara because it starts the web server in a thread.
# ActiveRecord::Base.shared_connection = ActiveRecord::Base.connection
#
# require 'rack/utils'
# Capybara.app = Rack::ShowExceptions.new(AliasMadness::Application)
#
#
# require 'json'
# module JSON
#   class << self
#     def parse(source, opts = {})
#       opts = ({:max_nesting => false}).merge(opts)
#       Parser.new(source, opts).parse
#     end
#   end
# end