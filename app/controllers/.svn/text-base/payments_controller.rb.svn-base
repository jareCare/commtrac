class PaymentsController < ApplicationController

  before_filter :parse_reasons,
    :only => :create

  def new
    @company = Company.find params[:company_id]
    @payment = current_user.payments.build
  end

  def create
    @company = Company.find params[:company_id]
    @payment = current_user.payments.build params[:payment]
    if @payment.save
      redirect_to payments_path(@company)
    else
      render :action => :new
    end
  end

  def index
    @company = Company.find params[:company_id]
    @payments = @company.payments.find :all
  end

  def destroy
    @company = Company.find params[:company_id]
    @payment = @company.payments.find params[:id]
    @payment.destroy
    flash[:notice] = 'Payment cancelled'
    redirect_to payments_path(@company)
  end

 private

  def parse_reasons
    if params.value?('1')
      reasons = params.select do |key, value| 
        value == '1' && 
          ! %w(company_id other).include?(key)
      end
      if params[:other]
        reasons << [params[:other_description], '1']
      end
      params[:payment][:reasons] = reasons.collect {|each| each[0]}
    end
  end

end
