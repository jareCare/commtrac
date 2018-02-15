class Admin::CompaniesController < Admin::BaseController

  def new
    @company = Company.new
  end

  def create
    @company = Company.new params[:company]
    if @company.save
      redirect_to admin_company_path(@company)
    else
      render :action => :new
    end
  end

  def index
    @companies = Company.find :all
  end

  def show
    @company = Company.find params[:id]
    if valid_end_date?
      @end_date = Time.local params[:end_date][:year].to_i,
        params[:end_date][:month].to_i,
        params[:end_date][:day].to_i
    end
  end

  def edit
    @company = Company.find params[:id]
  end

  def update
    @company = Company.find params[:id]
    if @company.update_attributes params[:company]
      redirect_to admin_company_path(@company)
    else
      render :action => :edit
    end
  end

  def destroy
    @company = Company.find params[:id]
    @company.destroy
    redirect_to admin_companies_path
  end

 private

  def valid_end_date?
    ! params[:end_date].nil? &&
      ! params[:end_date][:year].blank? &&
      ! params[:end_date][:month].blank? &&
      ! params[:end_date][:day].blank?
  end

end

