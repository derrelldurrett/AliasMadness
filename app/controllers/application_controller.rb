class ApplicationController < ActionController::Base
  require_relative '../errors/not_authorized'

  protect_from_forgery
  rescue_from User::NotAuthorized, with: :user_not_authorized

  private

  def user_not_authorized
    flash[:error] = %q(You don't have access to this section.)
    redirect_to :back
  end
end
