class Invoices::PictureController < ApplicationController

  def show
    @company = Company.find params[:company_id]
    @invoice = Invoice.find params[:invoice_id]
    @picture = @invoice.picture
    send_file @picture.full_filename,
      :content_type => @picture.content_type,
      :disposition => 'inline'
  end

end
