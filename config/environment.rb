# Load the Rails application.
require_relative 'application'

ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.default_options = { host: ENV['ALIASMADNESS_HOST'] }
ActionMailer::Base.smtp_settings = {
    user_name: ENV['ALIASMADNESS_EMAIL_USERNAME'],
    password: ENV['ALIASMADNESS_EMAIL_PASSWORD'],
    address: 'smtp.gmail.com',
    port: 587,
    authentication: :plain,
    enable_starttls_auto: true
}

# Initialize the Rails application.
Rails.application.initialize!
