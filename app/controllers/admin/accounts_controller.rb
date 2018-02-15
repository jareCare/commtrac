class Admin::AccountsController < Admin::BaseController

  helper :payments 

  def new
    @company = Company.find params[:company_id]
    @account = @company.accounts.build 
  end

  def create
    @company = Company.find params[:company_id]
    @account = @company.accounts.build params[:account]
    if @account.save
      redirect_to admin_account_path(@account)
    else
      render :action => :new
    end
  end

  def index
    @accounts = Account.find :all
  end

  def show
    @account = Account.find params[:id]
  end

  def edit
    @account = Account.find params[:id]
  end

  def update
    @account = Account.find params[:id]
    if @account.update_attributes params[:account]
      redirect_to admin_account_path(@account)
    else
      render :action => :edit
    end
  end

  def destroy
    @account = Account.find params[:id]
    @account.destroy
    redirect_to admin_accounts_path
  end

end
