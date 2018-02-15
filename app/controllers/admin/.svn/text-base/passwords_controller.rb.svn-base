class Admin::PasswordsController < Admin::BaseController

  def new
    @user = User.find params[:user_id]
    @user.password = ''
  end

  def create
    @user = User.find params[:user_id]
    if @user.update_attributes params[:user]
      redirect_to admin_user_path(@user)
    else
      render :action => :new
    end
  end

end
