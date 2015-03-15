module MailHelper
  def construct_player_email_to_field(player)
    %Q(#{player.name} <#{player.email}>)
  end
end
