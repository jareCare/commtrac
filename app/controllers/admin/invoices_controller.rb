class Admin::InvoicesController < Admin::BaseController

  def new
    @payment = Payment.find params[:payment_id]
    @invoice = @payment.invoices.build
  end

  def create
    @payment = Payment.find params[:payment_id]
    @invoice = @payment.invoices.build params[:invoice]
    if @invoice.save
      redirect_to admin_invoice_path(@invoice)
    else
      render :action => :new
    end
  end

  def index
    @invoices = Invoice.find :all,
      :order => 'start_date'
  end

  def show
    @invoice = Invoice.find params[:id]
  end

  def destroy
    @invoice = Invoice.find params[:id]
    @invoice.destroy
    redirect_to admin_invoices_path
  end

end
