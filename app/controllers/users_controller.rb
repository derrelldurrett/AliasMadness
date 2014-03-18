class UsersController < ApplicationController
  include SessionsHelper

  def login
    @user = User.find(params[:id])
  end

  def new
    if !signed_in?
      redirect_to root_path
    end
    @user = User.new
  end

  def update
    @user = User.find(params[:id])
    session_authenticate(@user)
  end

  def show
    @user = User.find(params[:id])
    @bracket = @user.bracket
  end

  def create
    if signed_in?
      begin
        params[:user][:role]='player'
        @user = User.create!(params[:user])
        UserMailer.welcome_email(@user).deliver if !@user.admin?
        flash.now[:success] = %Q(User '#{ params[:user][:name] }' created.)
      rescue Exception => e
        User.delete(@user)
        flash.now[:error] = %Q(Player '#{ params[:user][:name] }' not invited)
      end
      @user = User.new # clear the previous form data
      render new_user_path
    else
      redirect_to root_path
    end
  end
end
