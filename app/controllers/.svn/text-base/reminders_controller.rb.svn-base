class RemindersController < ApplicationController

  skip_before_filter :authenticate, 
    :only => [:new, :create]

  def new
  end

  def create
    @user = User.find_by_email params[:email]
    if @user.nil?
      flash.now[:notice] = 'Unknown email'
      render :action => :new
    else
      RemindersMailer.deliver_password_reminder @user
      flash[:notice] = 'A password reminder email has been sent'
      redirect_to new_session_path
    end
  end

end
