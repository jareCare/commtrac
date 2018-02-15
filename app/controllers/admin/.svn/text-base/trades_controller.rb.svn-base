class Admin::TradesController < Admin::BaseController

  helper :trades

  def new
    @trade = Trade.new
  end

  def create
    @trade = Trade.new params[:trade]
    if @trade.save
      redirect_to admin_trade_path(@trade)
    else
      render :action => :new
    end
  end

  def index
  end

  def show
    @trade = Trade.find params[:id]
  end

  def search
    if valid_company? &&
       valid_execution_type? && 
       valid_start_date? && 
       valid_end_date? 
      @start_date = Date.new params[:start_date][:year].to_i,
        params[:start_date][:month].to_i,
        params[:start_date][:day].to_i
      @end_date = Date.new params[:end_date][:year].to_i,
        params[:end_date][:month].to_i,
        params[:end_date][:day].to_i
      @company = Company.find params[:company_id]
      if all_execution_types?
        @trades, @totals = @company.trades.search_with_totals :time_span => @start_date..@end_date,
          :page => params[:page]
      else
        @trades, @totals = @company.trades.search_with_totals :time_span => @start_date..@end_date,
          :execution_type => params[:execution_type],
          :page => params[:page]
      end
    else
      flash.now[:notice] = 'Please select a company, execution type and date range'
      render :action => :search
    end
  end

  def edit
    @trade = Trade.find params[:id]
  end

  def update
    @trade = Trade.find params[:id]
    if @trade.update_attributes params[:trade]
      redirect_to admin_trade_path(@trade)
    else
      render :action => :edit
    end
  end

  def destroy
    @trade = Trade.find params[:id]
    @trade.destroy
    redirect_to admin_trades_path
  end

 private

  def valid_execution_type?
    ! params[:execution_type].blank?
  end

  def valid_company?
    ! params[:company_id].blank?
  end

  def valid_start_date?
    ! params[:start_date].nil? && 
      ! params[:start_date].any? {|key, value| value.blank?}
  end

  def valid_end_date?
    ! params[:end_date].nil? && 
      ! params[:end_date].any? {|key, value| value.blank?}
  end

  def all_execution_types?
    params[:execution_type] == 'All'
  end

end
