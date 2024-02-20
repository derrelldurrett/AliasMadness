class Admin
  class MessagesController < ApplicationController
    include SessionsHelper
    include UsersHelper
    include MailHelper

    before_action :check_authorization_admin
    MESSAGE_KEYS = [:subject, :message, :to]
    PARAM_KEYS = [:subject, :message]

    def new
      @user = Admin.get
    end

    def create
      @user = Admin.get
      begin
        params = Hash.new
        resource_params.each_with_index {|p, i| params[PARAM_KEYS[i]] = p}
        params[:message] = CGI::escapeHTML(params[:message]).gsub(/\n/, '<br>').html_safe
        User.players.each do |p|
          params[:to] = player_email_to_field(p)
          puts params[:to]
          MessageMailer.message_mail(params.slice(*MESSAGE_KEYS)).deliver
        end
        flash.now[:success] = %Q(Message sent!)
      rescue  StandardError => e
        puts e.message
        e.backtrace.each {|t| puts t }
        flash.now[:error] = %Q/Message not sent! :-(/
      end
      flash.keep
      redirect_to new_admin_message_path and return
    end

    private

    def resource_params
      params.require(PARAM_KEYS)
    end

    def build_players_email_list(players)
      players.each_with_object([]) do |p, list|
        list << player_email_to_field(p)
      end
    end

  end

end
