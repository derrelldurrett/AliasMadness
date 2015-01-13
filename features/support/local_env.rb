require 'rubygems'

ENV['RAILS_ENV'] ||= 'test'

require 'cucumber/rails'
require 'capybara/rails'
require 'email_spec/cucumber'
require 'capybara/cucumber'
require 'selenium-webdriver'
chosen_capybara_driver = :selenium # :culerity # :webkit # :poltergeist
Capybara.javascript_driver = chosen_capybara_driver
Capybara.default_selector = :css
Capybara.default_wait_time = 15
ActionController::Base.allow_rescue = false


# Possible values are :truncation and :transaction
# The :transaction strategy is faster, but might give you threading problems.
# See https://github.com/cucumber/cucumber-rails/blob/master/features/choose_javascript_database_strategy.feature
Cucumber::Rails::Database.javascript_strategy = :truncation

# Remove/comment out the lines below if your app doesn't have a database.
# For some databases (like MongoDB and CouchDB) you may need to use :truncation instead.
# You may also want to configure DatabaseCleaner to use different strategies for certain features and scenarios.
# See the DatabaseCleaner documentation for details. Example:
#
require 'database_cleaner'
require 'database_cleaner/cucumber'
require 'rspec/rails'
begin
  DatabaseCleaner.strategy = :truncation
  DatabaseCleaner.clean_with!(:truncation)
  Capybara.default_wait_time = 15
  RSpec.configure do |config|
    config.use_transactional_fixtures = false
    config.use_transactional_examples = false
  end
rescue NameError
  raise "You need to add database_cleaner to your Gemfile (in the :test group) if you wish to use it."
end

Before('~@javascript') do #'~@no-txn', '~@selenium', '~@culerity', '~@celerity',
  DatabaseCleaner.strategy = :transaction
  Capybara.default_wait_time = 15
end
#

# Before do
#   DatabaseCleaner.start
# end

# After do |scenario|
#   DatabaseCleaner.clean
# end

#
# From https://github.com/cucumber/cucumber-rails/blob/master/History.md
# DatabaseCleaner.strategy = nil
#
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


require 'json/pure/parser'
module JSON
  class << self
    def parse(source, opts = {})
      opts = ({:max_nesting => false}).merge(opts)
      Parser.new(source, opts).parse
    end
  end
end

Before do
  DatabaseCleaner.start
  DatabaseCleaner.clean_with(:truncation)
  RSpec.configure do |config|
    config.use_transactional_fixtures = false
    config.use_transactional_examples = false
  end
end

Before('@javascript') do # @no-txn,@selenium,@culerity,@celerity,
  # { :except => [:widgets] } may not do what you expect here
  # as Cucumber::Rails::Database.javascript_strategy overrides
  # this setting.
  DatabaseCleaner.strategy = :truncation
  Capybara.default_wait_time = 30
end

Around do |scenario, block|
  DatabaseCleaner.cleaning(&block)
  puts 'CLEANED!'
end

