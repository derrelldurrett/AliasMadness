# frozen_string_literal: true

class Admin
  class MessagesController < ApplicationController
    include SessionsHelper
    include UsersHelper
    include MailHelper

    before_action :check_authorization_admin
    MESSAGE_KEYS = %i[subject message to].freeze
    PARAM_KEYS = %i[subject message].freeze

    def new
      @user = Admin.get
    end

    # @return [Object] (An HTTP::Response)
    def create
      @user = Admin.get
      begin
        params = {}
        resource_params.each_with_index { |p, i| params[PARAM_KEYS[i]] = p }
        params[:message] = CGI.escapeHTML(params[:message]).gsub(/\n/, '<br>').html_safe
        get_players.each do |p|
          params[:to] = player_email_to_field(p)
          MessageMailer.message_mail(params.slice(*MESSAGE_KEYS)).deliver
        end
        flash.now[:success] = %(Message sent!)
      rescue StandardError => e
        puts e.message
        e.backtrace.each { |t| puts t }
        flash.now[:error] = %/Message not sent! :-(/
      end
      flash.keep
      redirect_to new_admin_message_path
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
