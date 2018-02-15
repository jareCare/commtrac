class Admin::PaymentsController < Admin::BaseController

  helper :payments

  before_filter :already_accepted?, 
    :only => [:edit, :update]

  def index
    @payments = Payment.find :all
  end

  def show
    @payment = Payment.find params[:id]
  end

  def edit
    @payment = Payment.find params[:id]
  end

  def update
    @payment = Payment.find params[:id]
    if accepted?
      @payment.accept!
      redirect_to admin_new_invoice_path(:payment_id => @payment)
    else
      @payment.reject!
      redirect_to admin_payments_path
    end
  end

 private

  def already_accepted?
    payment = Payment.find params[:id]
    if payment.accepted?
      redirect_to admin_payments_path
    end
  end

  def accepted?
    params[:decision] == 'yes'
  end    

end
