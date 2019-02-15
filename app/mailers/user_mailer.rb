class UserMailer < ApplicationMailer
  include MailHelper
  default from: ENV['ALIASMADNESS_SERVEREMAIL']

  def welcome_email(u, r)
    u.reload
    @user = u
    @url = construct_user_response_url(u)
    name_in_email = player_email_to_field(@user)
    @r = r
    mail(from: ENV['ALIASMADNESS_SERVEREMAIL'], to: name_in_email, subject: %Q(Welcome, #{@user.name}, to Alia's Madness!))
  end

  private

  def construct_user_response_url(u)
    # first pass doesn't bother with encryption
    puts 'ALIASMADNESS_HOST nil? ' + ENV['ALIASMADNESS_HOST'].nil?.to_s
    ENV['ALIASMADNESS_HOST'] + '/login?' +
      build_params(u).to_query(nil)
  end

  def build_params(u)
    params = {}
    params.store 'email', (u.send :email)
    params
  end
end
