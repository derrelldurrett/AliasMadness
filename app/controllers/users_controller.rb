# frozen_string_literal: true
require 'active_record/errors'
class UsersController < ApplicationController

  include SessionsHelper
  include UsersHelper
  before_action :check_authorization_admin, only: [:create]

  def login
    @user = User.find resource_params(:user_id)
  end

  def new
    unless signed_in?
      redirect_to root_path
    end
    @user = User.new
  end

  def update
    @user = User.find resource_params(:id)
    @user.password= resource_params()[:password]
    session_authenticate(@user)
  end

  def show
    if signed_in?
      begin
        @user = User.find resource_params(:id)
        @bracket = @user.bracket
        @players = get_players_sorted_by_score
        @disabled = current_user != @user
      rescue ActiveRecord::RecordNotFound => e
        logger.info e.message
        all = User.all
        all.each {|u| puts 'user: ' + u.name + ' : ' + u.id.to_s}
      end
    end
  end

  def create
    if signed_in?
      params = resource_params
      begin
        @user = create_player params
        flash.now[:success] = %Q(User '#{ params[:name] }' created.)
      rescue StandardError => e
        puts e.message
        e.backtrace.each {|t| puts t }
        User.delete(@user)
        flash.now[:error] = %Q(#{e.message};\nPlayer '#{ params[:name] }' not invited)
      end
      @user = User.new # clear the previous form data
      render new_user_path
    else
      redirect_to root_path
    end
  end

  private

  def resource_params(field = :user)
    case field
    when :user
      params.require(:user).permit(:name, :password, :password_confirmation, :email, :role)
    else
      params.require(field)
    end
  end
end
