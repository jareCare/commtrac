class UsersController < ApplicationController

  def show
    @company = Company.find params[:company_id]
    @user = @company.users.find params[:id]
    if valid_end_date?
      @end_date = Time.local params[:end_date][:year].to_i,
        params[:end_date][:month].to_i,
        params[:end_date][:day].to_i
    end
  end

 private

  def valid_end_date?
    ! params[:end_date].nil? &&
      ! params[:end_date][:year].blank? &&
      ! params[:end_date][:month].blank? &&
      ! params[:end_date][:day].blank?
  end

end
