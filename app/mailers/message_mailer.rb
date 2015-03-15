class MessageMailer < ActionMailer::Base
  include MailHelper
  include UsersHelper

  def message_mail(args)
    @subject= args[:subject]
    @message= args[:message].gsub(/\n/, '<br>').html_safe if args[:message].html_safe?
    get_players.each_slice(20) do |p_slice|
      mail(from: ENV['ALIASMADNESS_SERVEREMAIL'], to: build_players_email_list(p_slice), subject: @subject)
    end
  end

  private

  def build_players_email_list(players)
    list=[]
    players.each do |p|
      list<< construct_player_email_to_field(p)
    end
    list.join(',')
  end
end
