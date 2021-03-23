# frozen_string_literal: true
module MailHelper
  def player_email_to_field(player)
    puts %(Sending mail to "#{player.name} <#{player.email}>")
    %(#{player.name} <#{player.email}>)
  end
end
