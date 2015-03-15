class Admin
  class MessagesController < ApplicationController
    include SessionsHelper
    before_filter :check_authorization
    MESSAGE_KEYS=[:subject, :message]

    def new
      @user= Admin.get
    end

    def create
      MessageMailer.message_mail(params.slice(*MESSAGE_KEYS)).deliver
      @user=Admin.get
      render new_admin_message_path and return
    end
  end
end
