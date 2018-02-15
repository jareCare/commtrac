class Admin::OrganizationsController < Admin::BaseController

  def new
    @organization = Organization.new
  end

  def create
    @organization = Organization.new params[:organization]
    if @organization.save
      redirect_to admin_organization_path(@organization)
    else
      render :action => :new
    end
  end

  def index
    @organizations = Organization.find :all
  end

  def show
    @organization = Organization.find params[:id]
  end

  def edit
    @organization = Organization.find params[:id]
  end

  def update
    @organization = Organization.find params[:id]
    if @organization.update_attributes params[:organization]
      redirect_to admin_organization_path(@organization)
    else
      render :action => :edit
    end
  end

  def destroy
    @organization = Organization.find params[:id]
    @organization.destroy
    redirect_to admin_organizations_path
  end

end
