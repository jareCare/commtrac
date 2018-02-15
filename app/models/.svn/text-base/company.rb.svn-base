class Company < ActiveRecord::Base

  has_many :trades, :dependent => :destroy
  has_many :accounts, :dependent => :destroy
  has_many :payments, :through => :accounts
  has_many :organizations, :through => :accounts
  has_many :vendors, 
    :through => :accounts,
    :source => :organization,
    :conditions => {
      :organization_type => 'Vendor'
    }
  has_many :brokers, 
    :through => :accounts,
    :source => :organization,
    :conditions => {
      :organization_type => 'Broker'
    }
  has_many :users, :dependent => :destroy

  validates_presence_of :name
  validates_numericality_of :credit_rate,
    :best_commission_rate,
    :soft_commission_rate

  def cover?(amount)
    credit_balance >= amount
  end

  def credit_balance
    credit_accrued = trades.sum(:credit_accrued,
                                :conditions => ['made_on <= ?', Date.today])
    processed_payments = payments.sum(:amount,
                                      :conditions => {
                                        :status => 'Processed'
                                      })
    (credit_accrued || 0) -
      (processed_payments || 0)
  end

  def commission_paid_mtd_up_to(date)
    trades.sum(:commission_paid,
               :conditions => { :made_on => date.beginning_of_month..date }) || 0
  end
  
  def commission_paid_ytd_up_to(date)
    trades.sum(:commission_paid,
               :conditions => { :made_on => date.beginning_of_year..date }) || 0
  end

  def soft_commission_paid_mtd_up_to(date)
    trades.sum(:commission_paid,
               :conditions => { 
                 :made_on => date.beginning_of_month..date,
                 :execution_type => 'SOFT' 
               }) || 0
  end

  def soft_commission_paid_ytd_up_to(date)
    trades.sum(:commission_paid,
               :conditions => { 
                 :made_on => date.beginning_of_year..date,
                 :execution_type => 'SOFT' 
               }) || 0
  end

  def best_commission_paid_mtd_up_to(date)
    trades.sum(:commission_paid,
               :conditions => { 
                 :made_on => date.beginning_of_month..date,
                 :execution_type => %w(BEST AUTO)
               }) || 0
  end

  def best_commission_paid_ytd_up_to(date)
    trades.sum(:commission_paid,
               :conditions => { 
                 :made_on => date.beginning_of_year..date,
                 :execution_type => %w(BEST AUTO) 
               }) || 0
  end

  def prior_year_credits_accrued(date)
    end_of_prior_year = Time.local date.year - 1, 12, 31
    processed_payments = payments.sum(:amount,
                                      :conditions => ['processed_on <= ?
                                                       and status = ?', 
                                                      end_of_prior_year,
                                                      'Processed'])
    pending_and_accepted_payments = payments.sum(:amount,
                                                 :conditions => ['payments.created_on <= ?
                                                                  and status in (?)',
                                                                 end_of_prior_year,
                                                                 ['Pending', 
                                                                  'Accepted']])
    total_payments = (processed_payments || 0) +
      (pending_and_accepted_payments || 0)
    credit_accrued = trades.sum(:credit_accrued,
                                :conditions => ['made_on <= ?', 
                                                end_of_prior_year])
    (credit_accrued || 0) - 
      total_payments
  end

  def credits_accrued_mtd_up_to(date)
    trades.sum(:credit_accrued,
               :conditions => { :made_on => date.beginning_of_month..date }) || 0
  end

  def credits_accrued_ytd_up_to(date)
    trades.sum(:credit_accrued,
               :conditions => { :made_on => date.beginning_of_year..date }) || 0
  end

  def total_credits_accrued_mtd_up_to(date)
    credits_accrued_mtd_up_to date
  end

  def total_credits_accrued_up_to(date)
    prior_year_credits_accrued(date) +
      credits_accrued_ytd_up_to(date)
  end

  def processed_payments_mtd_up_to(date)
    payments.sum(:amount,
                 :conditions => { 
                   :processed_on => date.beginning_of_month..date,
                   :status => 'Processed' 
                 }) || 0
  end

  def processed_payments_ytd_up_to(date)
    payments.sum(:amount,
                 :conditions => { 
                   :processed_on => date.beginning_of_year..date,
                   :status => 'Processed' 
                 }) || 0
  end

  def pending_and_accepted_payments_mtd_up_to(date)
    payments.sum(:amount,
                 :conditions => ['payments.created_on between ? and ?
                                  and status in (?)',
                                 date.beginning_of_month,
                                 date,
                                 ['Pending', 
                                  'Accepted']]) || 0
  end

  def pending_and_accepted_payments_ytd_up_to(date)
    payments.sum(:amount,
                 :conditions => ['payments.created_on between ? and ?
                                  and status in (?)',
                                 date.beginning_of_year,
                                 date,
                                 ['Pending', 
                                  'Accepted']]) || 0
  end

  def credit_balance_mtd_up_to(date)
    payments_made_mtd = processed_payments_mtd_up_to(date) + 
      pending_and_accepted_payments_mtd_up_to(date)
    credits_accrued_mtd_up_to(date) - payments_made_mtd
  end

  def credit_balance_up_to(date)
    payments_made_ytd = processed_payments_ytd_up_to(date) + 
      pending_and_accepted_payments_ytd_up_to(date)
    total_credits_accrued_up_to(date) - payments_made_ytd
  end

end
