class UserMailer < ActionMailer::Base
  default reply_to: ENV['ALIASMADNESS_ADMINEMAIL']
  default from: ENV['ALIASMADNESS_ADMINEMAIL']

  def welcome_email(u, r)
    u.reload
    @user = u
    @url = construct_user_response_url(u, r)
    name_in_email = %Q(#{@user.name} <#{@user.email}>)
    mail(from: Admin.get.email, to: name_in_email, subject: %Q(Welcome, #{@user.name}, to Alia's Madness!))
    puts 'user nil' if u.nil?.to_s
    puts '@url nil' if @url.nil?.to_s
    puts 'user: '+u.email+' token: '+@url
  end

  private

  def construct_user_response_url(u, r)
    # first pass doesn't bother with encryption
    puts 'ALIASMADNESS_HOST nil? '+ENV['ALIASMADNESS_HOST'].nil?.to_s
    ENV['ALIASMADNESS_HOST']+'/login?'+
        build_params(u, r).to_query
  end

  def build_params(u, r)
    params = {}
    params.store 'email', (u.send :email)
    params.store 'password', r
    params
  end
end
