class MessageMailer < ActionMailer::Base
  def message_mail(args)
    @subject= args[:subject]
    @message= args[:message]
    mail(from: ENV['ALIASMADNESS_SERVEREMAIL'], to: args[:to], subject: @subject)
  end

end
