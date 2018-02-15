class Admin::PicturesController < Admin::BaseController

  def new
    @invoice = Invoice.find params[:invoice_id]
    @picture = @invoice.build_picture
  end

  def create
    @invoice = Invoice.find params[:invoice_id]
    unless params[:picture][:uploaded_data].blank?
      @picture = @invoice.build_picture params[:picture]
      @picture.save
    end
    redirect_to admin_invoice_path(@invoice)
  end

  def show
    @picture = Picture.find params[:id]
    send_file @picture.full_filename,
      :content_type => @picture.content_type,
      :disposition => 'inline'
  end

  def destroy
    @picture = Picture.find params[:id]
    @picture.destroy
    redirect_to admin_invoice_path(@picture.subject)
  end

end
