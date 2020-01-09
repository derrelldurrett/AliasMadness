class MessageMailer < ApplicationMailer

  def message_mail(args)
    @subject= args[:subject]
    @message= args[:message]
    mail(to: args[:to], subject: @subject)
  end

end
