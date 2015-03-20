source 'https://rubygems.org'

gem 'rails', '3.2.21'
gem 'simple_roles'
gem 'rgl'
gem 'simple_form'
gem 'bcrypt-ruby', '~> 3.0.0'
gem 'active_attr'
gem 'sprockets'
gem 'pg'
gem 'coffee-rails'
gem 'postmark-rails'
gem 'uglifier'#, '>= 1.0.3'
# gem 'i18n'
# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

group :production do
  gem 'rails_12factor'
  gem 'lograge'
end

group :development, :test do
  gem 'rspec'#, '>= 2.14'
  gem 'rspec-rails'
  gem 'guard-rspec'
  gem 'factory_girl_rails'
  gem 'faker'
  gem 'bootstrap-generators'
end

group :production, :development do
  gem 'unicorn'
  gem 'lograge'
end

group :test do
  gem 'capybara'
  gem 'capybara-screenshot'
  gem 'shoulda'#, '>3.1.1'
  gem 'cucumber-rails', :require => false
  gem 'database_cleaner'
  gem 'email_spec'
  gem 'selenium-webdriver'
  gem 'launchy'
  gem 'rb-inotify'#, '0.8.8' # linux
  gem 'libnotify'#, '0.5.9' # linux
#  gem 'rb-fsevent', :require => false # OS X
#  gem 'growl'                         # OS X
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails' #, '~> 4.0.0'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'therubyracer', :platforms => :ruby

end

gem 'jquery-rails'

ruby '2.1.5'
