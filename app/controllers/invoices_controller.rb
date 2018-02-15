class InvoicesController < ApplicationController

  def show
    @company = Company.find params[:company_id]
    @invoice = Invoice.find params[:id]
  end

  def index
    @company = Company.find params[:company_id]
    if start_date? && 
       end_date? &&
       organization? 
      options = {}
      @start_date = Date.new params[:start_date][:year].to_i,
        params[:start_date][:month].to_i,
        params[:start_date][:day].to_i
      @end_date = Date.new params[:end_date][:year].to_i,
        params[:end_date][:month].to_i,
        params[:end_date][:day].to_i
      options[:time_span] = @start_date..@end_date
      if all?
        @vendors = 'All'
        @brokers = 'All'
        options[:vendors] = @company.vendors
        options[:brokers] = @company.brokers
      elsif all_vendors?
        @vendors = 'All'
        options[:vendors] = @company.vendors
      elsif all_brokers?
        @brokers = 'All'
        options[:brokers] = @company.brokers
      else
        @organization = Organization.find params[:organization_id]
        if @organization.broker?
          options[:brokers] = [@organization]
        else
          options[:vendors] = [@organization]
        end
      end
      @invoices = Invoice.search @company, options
    else
      flash.now[:notice] = 'Please select a vendor/broker and date range'
      render :action => :index
    end
  end

 private 

  def start_date?
    ! params[:start_date].nil? && 
      ! params[:start_date].any? {|key, value| value.blank?}
  end

  def end_date?
    ! params[:end_date].nil? && 
      ! params[:end_date].any? {|key, value| value.blank?}
  end

  def organization?
    ! params[:organization_id].nil?
  end

  def all?
    params[:organization_id] == 'All'
  end		

  def all_vendors?
    params[:organization_id] == 'All Vendors'
  end

  def all_brokers?
    params[:organization_id] == 'All Brokers'
  end

end
