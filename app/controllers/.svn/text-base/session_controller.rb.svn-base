class SessionController < ApplicationController

  skip_before_filter :authenticate, 
    :only => [:new, :create]

  def new
  end

  def create
    @user = User.authenticate params[:email], params[:password]
    if @user.nil?
      flash.now[:notice] = 'Invalid email and/or password'
      render :action => :new
    else
      session[:user_id] = @user.id
      if remember_me?
        @user.remember_me!
        cookies[:token] = { 
          :value => @user.token,
          :expires => 1.month.from_now 
        }
      end
      if @user.admin?
        redirect_to admin_companies_path
      else
        redirect_to user_path(@user.company, @user)
      end
    end
  end

  def destroy
    session[:user_id] = nil
    cookies.delete :token
    redirect_to new_session_path
  end

 private

  def remember_me?
    params[:remember_me]== '1'
  end

end
