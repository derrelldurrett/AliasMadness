module MailHelper
  def player_email_to_field(player)
    puts player.name + player.email
    %Q(#{player.name} <#{player.email}>)
  end
end
