class MessageMailer < ApplicationMailer

  def message_mail(args)
    puts args.to_s
    @subject= args[:subject]
    @message= args[:message]
    mail(to: args[:to], subject: @subject)
  end

end
