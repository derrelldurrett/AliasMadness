class ApplicationMailer < ActionMailer::Base
  include SendGrid

  default from: ENV['ALIASMADNESS_SERVEREMAIL'],
          reply_to: ENV['ALIASMADNESS_ADMINEMAIL'],
          headers: {'Authorization' => 'Bearer ' + ENV['ALIASMADNESS_SENDGRID_API_KEY']}
  layout 'mailer'
end
