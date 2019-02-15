# using SendGrid's Ruby Library
# https://github.com/sendgrid/sendgrid-ruby
require 'sendgrid-ruby'
include SendGrid

from = Email.new(email: ENV['ALIASMADNESS_SERVEREMAIL'])
to = Email.new(email: ENV['TARGET_EMAIL'])
subject = 'Sending with SendGrid is Fun'
content = Content.new(type: 'text/plain', value: 'and easy to do anywhere, even with Ruby')
mail = Mail.new(from, subject, to, content)
mail.headers['Authorization'] = ENV['ALIASMADNESS_SENDGRID_API_KEY']
sg = SendGrid::API.new(api_key: ENV['ALIASMADNESS_SENDGRID_API_KEY'])
puts ENV['ALIASMADNESS_SENDGRID_API_KEY']
response = sg.client.mail._('send').post(request_body: mail.to_json)
puts response.status_code
puts response.body
puts response.headers