class UserMailer < ActionMailer::Base
  default reply_to: ENV['ALIASMADNESS_ADMINEMAIL']
  default from: ENV['ALIASMADNESS_ADMINEMAIL']

  def welcome_email(u)
    @user = u
    @url = construct_user_response_url(u)
    name_in_email = %Q(#{@user.name} <#{@user.email}>)
    mail(from: Admin.get.email, to: name_in_email, subject: %Q(Welcome, #{@user.name}, to Alia's Madness!))
    puts 'user nil' if u.nil?
    puts '@url nil' if @url.nil?
    puts 'user: '+u.email+' token: '+@url
  end

  private

  def construct_user_response_url(u)
    # first pass doesn't bother with encryption
    puts 'ALIASMADNESS_HOST nil? '+ENV['ALIASMADNESS_HOST'].nil?
    ENV['ALIASMADNESS_HOST']+'/login?'+
        build_params(u).to_query
  end

  def build_params(u)
    messages_for_query = [:email,:remember_for_email]
    params = {}
    messages_for_query.each do |m|
      params.store m.to_s,(u.send m)
    end
    params
  end
end
