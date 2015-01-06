class SessionsController < ApplicationController
  include SessionsHelper
  #def new
  #end
  #
  #def create
  #  user = User.find_by_email(params[:session][:email])
  #
  #  session_authenticate(user)
  #end
  #
  #def destroy
  #  sign_out
  #  redirect_to root_path
  #end

  def login
    reset_session
    @user = User.find_by_email(params[:email])
    if @user.nil?
      redirect_to(root_path) and return
    end
    if current_user? @user
      redirect_to user_path id: @user.id
    end
    redirect_to(login_users_path id: @user.id)
  end
end
