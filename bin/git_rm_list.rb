#!/usr/bin/env ruby
puts `pwd`
files = 'vendor/cache/actionmailer-3.2.21.gem
vendor/cache/actionpack-3.2.21.gem
vendor/cache/activemodel-3.2.21.gem
vendor/cache/activerecord-3.2.21.gem
vendor/cache/activeresource-3.2.21.gem
vendor/cache/activesupport-3.2.21.gem
vendor/cache/addressable-2.3.7.gem
vendor/cache/capybara-screenshot-1.0.5.gem
vendor/cache/coffee-script-source-1.9.0.gem
vendor/cache/cucumber-1.3.19.gem
vendor/cache/execjs-2.3.0.gem
vendor/cache/lograge-0.3.1.gem
vendor/cache/postmark-1.5.0.gem
vendor/cache/postmark-rails-0.10.0.gem
vendor/cache/rails-3.2.21.gem
vendor/cache/railties-3.2.21.gem
vendor/cache/rspec-3.2.0.gem
vendor/cache/rspec-core-3.2.0.gem
vendor/cache/rspec-expectations-3.2.0.gem
vendor/cache/rspec-mocks-3.2.0.gem
vendor/cache/rspec-rails-3.2.0.gem
vendor/cache/rspec-support-3.2.1.gem
vendor/cache/rubyzip-1.1.7.gem
vendor/cache/sass-3.4.12.gem
vendor/cache/shoulda-matchers-2.8.0.gem
vendor/cache/tzinfo-0.3.43.gem'
files.split("\n").each {|f| puts "rm #{f}"; system("git rm #{f}")}