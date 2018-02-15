class ApplicationController < ActionController::Base

  session :session_key => '_nutmegcommtrac_session_id'

  include ExceptionNotifiable

  helper_method :logged_in?,
    :current_user

  before_filter :cookie?, 
    :authenticate

  def cookie?
    unless cookies[:token].blank? 
      user = User.find_by_token cookies[:token]
      session[:user_id] = user.id
    end
  end

  def authenticate
    unless logged_in?
      flash[:notice] = 'Please login'
      redirect_to new_session_path and return false
    end
  end

  def logged_in?
    ! session[:user_id].nil?
  end

  def current_user
    @current_user ||= User.find session[:user_id]
  end

end
