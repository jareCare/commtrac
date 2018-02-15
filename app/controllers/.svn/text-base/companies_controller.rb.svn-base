class CompaniesController < ApplicationController

  before_filter :home_page,
    :only => :index

  def show
    @company = Company.find params[:id]
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

  def home_page
    if current_user.admin?
      redirect_to admin_companies_path
    else
      redirect_to user_path(current_user.company, current_user)
    end
  end

end
