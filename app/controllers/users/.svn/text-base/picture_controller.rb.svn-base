class Users::PictureController < ApplicationController

  def new
    @company = Company.find params[:company_id]
    @user = @company.users.find params[:user_id]
    @picture = @user.build_picture
  end

  def create
    @company = Company.find params[:company_id]
    @user = @company.users.find params[:user_id]
    unless params[:picture][:uploaded_data].blank?
      @picture = @user.build_picture params[:picture]
      @picture.save
    end
    redirect_to user_path(@company, @user)
  end

  def show
    @company = Company.find params[:company_id]
    @user = @company.users.find params[:user_id]
    @picture = @user.picture
    send_file @picture.full_filename,
      :content_type => @picture.content_type,
      :disposition => 'inline'
  end

  def destroy
    @company = Company.find params[:company_id]
    @user = @company.users.find params[:user_id]
    @picture = @user.picture
    @picture.destroy
    redirect_to user_path(@company, @user)
  end

end
