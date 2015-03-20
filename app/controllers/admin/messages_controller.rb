class Admin
  class MessagesController < ApplicationController
    include SessionsHelper
    include UsersHelper
    include MailHelper

    before_filter :check_authorization
    MESSAGE_KEYS=[:subject, :message, :to]

    def new
      @user= Admin.get
    end

    def create
      params[:message]= CGI::escapeHTML(params[:message]).gsub(/\n/, '<br>').html_safe
      get_players.each_slice(20) do |p_slice|
        params[:to]= build_players_email_list p_slice
        MessageMailer.message_mail(params.slice(*MESSAGE_KEYS)).deliver
      end
      @user=Admin.get
      render new_admin_message_path and return
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

end
