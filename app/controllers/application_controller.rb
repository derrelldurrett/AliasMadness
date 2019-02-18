require "application_responder"

class ApplicationController < ActionController::Base
  self.responder = ApplicationResponder
  respond_to :json
  before_action :check_authorization

  protect_from_forgery with: :exception

  def check_authorization
    !current_user.nil?
  end

  def check_authorization_admin
    current_user.admin?
  end
end
