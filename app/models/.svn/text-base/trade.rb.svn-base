class Trade < ActiveRecord::Base

  EXECUTION_TYPES = %w(BEST SOFT AUTO)

  belongs_to :company

  validates_presence_of :direction,
    :symbol,
    :made_on,
    :company_id
  validates_numericality_of :quantity, 
    :only_integer => true
  validates_numericality_of :average_price
  validates_inclusion_of :execution_type,
    :in => EXECUTION_TYPES

  before_save :calculate_credit_accrued,
    :calculate_commission_paid

  def self.search_with_totals(options)
    if options[:execution_type].blank?
      trades = paginate :all,
        :conditions => { :made_on => options[:time_span] },
        :order => 'made_on, symbol, direction',
        :page => options[:page]
      totals = connection.select_one "select sum(quantity) as quantity,
                                             sum(credit_accrued) as credit_accrued,
                                             sum(commission_paid) as commission_paid
                                      from trades
                                      where made_on between '#{connection.quote_string options[:time_span].begin.to_s(:db)}'
                                        and '#{connection.quote_string options[:time_span].end.to_s(:db)}'"
      return [trades, totals]
    else
      trades = paginate :all,
        :conditions => { :made_on => options[:time_span],
                         :execution_type => options[:execution_type] },
        :order => 'made_on, symbol, direction',
        :page => options[:page]
      totals = connection.select_one "select sum(quantity) as quantity,
                                             sum(credit_accrued) as credit_accrued,
                                             sum(commission_paid) as commission_paid
                                      from trades
                                      where made_on between '#{connection.quote_string options[:time_span].begin.to_s(:db)}'
                                        and '#{connection.quote_string options[:time_span].end.to_s(:db)}'
                                        and execution_type = '#{connection.quote_string options[:execution_type]}'"
      return [trades, totals]
    end
  end

  def self.from_array(array)
    execution_type = if array[5] == 'KAMASLOW' ||
                         array[6] == 'CSA' ||
                         array[6] == 'csa' ||
                         array[5] == 'MELLON'
                       'SOFT'
                     else
                       'BEST'
                     end
    new :made_on => Date.parse(array[0]),
      :symbol => array[1],
      :direction => array[2],
      :quantity => array[3].to_i,
      :average_price => array[4].to_f,
      :execution_type => execution_type
  end

  def soft?
    execution_type == 'SOFT'
  end

  def best?
    execution_type == 'BEST'
  end

  def auto?
    execution_type == 'AUTO'
  end

 protected

  def calculate_credit_accrued
    if soft?
      self.credit_accrued = company.credit_rate * quantity / 100
    else
      self.credit_accrued = 0.0
    end
  end

  def calculate_commission_paid
    if soft?
      self.commission_paid = company.soft_commission_rate * quantity / 100
    else
      self.commission_paid = company.best_commission_rate * quantity / 100
    end
  end

end
