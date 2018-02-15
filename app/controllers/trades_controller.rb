class TradesController < ApplicationController

  def index
    @company = Company.find params[:company_id]
    if valid_execution_type? && 
       valid_start_date? && 
       valid_end_date? 
      @start_date = Date.new params[:start_date][:year].to_i,
        params[:start_date][:month].to_i,
        params[:start_date][:day].to_i
      @end_date = Date.new params[:end_date][:year].to_i,
        params[:end_date][:month].to_i,
        params[:end_date][:day].to_i
      if all_execution_types?
        @trades, @totals = @company.trades.search_with_totals :time_span => @start_date..@end_date,
          :page => params[:page]
      else
        @trades, @totals = @company.trades.search_with_totals :time_span => @start_date..@end_date,
          :execution_type => params[:execution_type],
          :page => params[:page]
      end
    else
      flash.now[:notice] = 'Please select an execution type and date range'
      render :action => :index
    end
  end

 private

  def valid_execution_type?
    ! params[:execution_type].blank?
  end

  def valid_start_date?
    ! params[:start_date].blank? && 
      ! params[:start_date].any? {|key, value| value.blank?}
  end

  def valid_end_date?
    ! params[:end_date].blank? && 
      ! params[:end_date].any? {|key, value| value.blank?}
  end

  def all_execution_types?
    params[:execution_type] == 'All'
  end

end
 
