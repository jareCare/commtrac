class Admin::UsersController < Admin::BaseController

  def new
    @user = User.new 
  end
    
  def create
    @user = User.new params[:user]
    if @user.save
      redirect_to admin_user_path(@user)
    else
      render :action => :new
    end
  end

  def index
    @users = User.find :all
  end

  def show
    @user = User.find params[:id]
    if valid_end_date?
      @end_date = Time.local params[:end_date][:year].to_i,
        params[:end_date][:month].to_i,
        params[:end_date][:day].to_i
    end
  end

  def edit
    @user = User.find params[:id]
  end

  def update
    @user = User.find params[:id]
    if @user.update_attributes params[:user]
      redirect_to admin_user_path(@user)
    else
      render :action => :edit
    end
  end

  def destroy
    @user = User.find params[:id]
    @user.destroy
    redirect_to admin_users_path
  end

 private

  def valid_end_date?
    ! params[:end_date].nil? &&
      ! params[:end_date][:year].blank? &&
      ! params[:end_date][:month].blank? &&
      ! params[:end_date][:day].blank?
  end

end
