# Load the Rails application.
require_relative 'application'

ActionMailer::Base.smtp_settings = {
    :user_name => ENV['ALIASMADNESS_SENDGRID_USERNAME'],
    :password => ENV['ALIASMADNESS_SENDGRID_PASSWORD'],
    :domain => ENV['ALIASMADNESS_DOMAIN'],
    :address => 'smtp.sendgrid.net',
    :port => 587,
    :authentication => :plain,
    :enable_starttls_auto => true
}

# Initialize the Rails application.
Rails.application.initialize!
