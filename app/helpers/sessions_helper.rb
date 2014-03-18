module SessionsHelper
  delegate :url_helpers, to: 'Rails.application.routes'
  def session_authenticate(user)
    id = params[:id]
    if user && user.authenticate(params[:user][:password])
      sign_in user
      redirect_back_or user
    else
      flash[:error] = 'Invalid email/password combination'
      sign_out
      redirect_to login_users_path(id: id)
    end
  end

  def sign_in(user)
    cookies.permanent[:remember_token] = user.remember_token
    self.current_user = user
  end

  def sign_out
    self.current_user = nil
    cookies.delete(:remember_token)
  end

  def signed_in?
    !current_user.nil?
  end

  def current_user=(user)
    @current_user = user
  end

  def current_user
    @current_user ||= User.find_by_remember_token(cookies[:remember_token])
  end

  def current_user?(user)
    user == current_user
  end

  def redirect_back_or(default)
    redirect_to(session[:return_to] || default)
    session.delete(:return_to)
  end

  def store_location
    session[:return_to] = request.fullpath
  end

  def signed_in_user
    unless signed_in?
      sign_in User.find_by_email(params[:user][:email])
    end
    unless signed_in?
      store_location
      redirect_to :back, notice: "Please sign in."
    end
  end

end
