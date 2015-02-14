class UsersController < ApplicationController
  require 'active_record/errors'

  include SessionsHelper
  before_filter :check_authorization, only: [:create]

  def login
    @user = User.find(params[:id])
  end

  def new
    unless signed_in?
      redirect_to root_path
    end
    @user = User.new
  end

  def update
    #reset_session
    @user = User.find(params[:id])
    session_authenticate(@user)
  end

  def show
    if signed_in?
      begin
        @user = User.find(params[:id])
        @bracket = @user.bracket
        @players = User.ordered_by_current_score
      rescue ActiveRecord::RecordNotFound => e
        puts e.message
        all= User.all
        all.each { |u| puts 'user: '+u.name+' : '+u.id.to_s }
      end
    else
      flash.now[:error]= 'user not signed in'
      @players=[]
    end
  end

  def create
    if signed_in?
      begin
        params[:user][:role]='player'
        set_player_login params
        @user = User.create!(params[:user])
        UserMailer.welcome_email(@user, @remember_for_email).deliver
        flash.now[:success] = %Q(User '#{ params[:user][:name] }' created.)
      rescue Exception => e
        puts e.message
        User.delete(@user)
        flash.now[:error] = %Q(#{e.message};\nPlayer '#{ params[:user][:name] }' not invited)
      end
      @user = User.new # clear the previous form data
      render new_user_path
    else
      redirect_to root_path
    end
  end

  private
  # def user_params
  #   params.require(:user).permit(:name, :password, :password_confirmation, :email, :role)
  # end

  def set_player_login(params)
    params[:user][:password] =
        params[:user][:password_confirmation] =
            @remember_for_email =
                SecureRandom.base64(24) #create a  32-character-length password
  end
end
