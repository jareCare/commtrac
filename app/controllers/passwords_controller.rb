class PasswordsController < ApplicationController

  skip_before_filter :authenticate,
    :only => [:new, :create]

  def new
    @user = User.find_by_id_and_password params[:_u],
      params[:_p]
    @user.password = ''
  end

  def create
    @user = User.find_by_id_and_password params[:_u],
      params[:_p]
    if @user.update_attributes params[:user]
      session[:user_id] = @user.id
      redirect_to user_path(@user.company, @user)
    else
      render :action => :new
    end
  end

end
