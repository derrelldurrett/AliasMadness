source 'https://rubygems.org'

gem 'rails', '3.2.13'
gem 'simple_roles'
gem 'rgl'
#gem 'bootstrap-sass'
gem 'simple_form'
gem 'bcrypt-ruby', '~> 3.0.0'
gem 'active_attr'
gem 'faker', '1.0.1'
gem 'sprockets'
gem 'pg'
gem 'sass-rails'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

group :production do
  gem 'rails_12factor'
end

group :development, :test do
  gem 'rspec'
  gem 'rspec-rails'
  gem 'guard-rspec'
  gem 'factory_girl'
  gem 'factory_girl_rails'
  gem 'bootstrap-generators'
  gem 'debase'
#  gem 'ruby-debug-base19x'
#  gem 'linecache19', '0.5.13', :git => 'https://github.com/robmathews/linecache19-0.5.13.git'
#  gem 'ruby-debug-base19x', '>=0.11.30.pre12'
#  gem 'ruby-debug19', :require => 'ruby-debug'
  gem 'ruby-debug-ide'#, '>= 0.4.17.beta17'
end

group :test do
  gem 'capybara'
  gem 'capybara-screenshot'
  gem 'shoulda', '>3.1.1'
  gem 'cucumber-rails', :require => false
  # database_cleaner is not required, but highly recommended
  gem 'database_cleaner'
  gem 'email_spec'
  gem 'rb-inotify', '0.8.8' # linux
  gem 'libnotify', '0.5.9' # linux
#  gem 'rb-fsevent', :require => false # OS X
#  gem 'growl'                         # OS X
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails'
  gem 'coffee-rails'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'

ruby '2.0.0'
