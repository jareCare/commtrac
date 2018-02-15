class AccountsController < ApplicationController

  helper :payments

  def show
    @company = Company.find params[:company_id]
    @account = @company.accounts.find params[:id]
  end

end
