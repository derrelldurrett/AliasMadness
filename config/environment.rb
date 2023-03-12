# Load the Rails application.
require_relative 'application'

ActionMailer::Base.delivery_method = :sendmail
ActionMailer::Base.default_options = {
  host: ENV['ALIASMADNESS_HOST'],
  reply_to: ENV['ALIASMADNESS_ADMINEMAIL']
}

# Initialize the Rails application.
Rails.application.initialize!
