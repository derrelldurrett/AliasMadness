require 'rubygems'

ENV['RAILS_ENV'] ||= 'test'

require 'capybara/rails'
require 'email_spec/cucumber'
require 'capybara/cucumber'
require 'selenium-webdriver'
require 'database_cleaner'
require 'database_cleaner/cucumber'
# require 'capybara/session'
# require 'capybara/poltergeist'
# require 'capybara/celerity'
# require 'capybara/culerity'
chosen_capybara_driver = :selenium # :culerity # :webkit # :poltergeist
Capybara.javascript_driver = chosen_capybara_driver
Capybara.default_selector = :css
Capybara.default_wait_time = 15
# DatabaseCleaner.strategy = :truncation
# begin
#   require 'database_cleaner'
#   require 'database_cleaner/cucumber'
#   DatabaseCleaner[:active_record].strategy = :truncation
# rescue NameError
#   raise "You need to add database_cleaner to your Gemfile (in the :test group) if you wish to use it."
# end
#

# Before do
#   DatabaseCleaner.start
# end
#
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

# Before do
#   if Capybara.current_driver == chosen_capybara_driver
#     require 'headless'
#
#     headless = Headless.new
#     headless.start
#   end
# end

require 'json/pure/parser'
module JSON
  class << self
    def parse(source, opts = {})
      opts = ({:max_nesting => false}).merge(opts)
      Parser.new(source, opts).parse
    end
  end
end

# Capybara.register_driver :culerity do |app|
#   Capybara::Driver::Culerity.new(app)
# end
# Culerity.jruby_invocation = File.expand_path("~/.rvm/bin/celerity_jruby")
