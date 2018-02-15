require File.dirname(__FILE__) + '/../test_helper'

class CompanyTest < Test::Unit::TestCase

  fixtures :companies, 
    :organizations,
    :trades, 
    :accounts, 
    :invoices, 
    :users,
    :payments

  def test_should_have_many_users
    company = Company.new

    assert company.respond_to?(:users)
    
    assert_raise(ActiveRecord::AssociationTypeMismatch) { company.users << Account.new }
  end

  def test_should_have_many_accounts
    company = Company.new

    assert company.respond_to?(:accounts)
    
    assert_raise(ActiveRecord::AssociationTypeMismatch) { company.accounts << User.new }
  end

  def test_should_have_many_trades
    company = Company.new

    assert company.respond_to?(:trades)
    
    assert_raise(ActiveRecord::AssociationTypeMismatch) { company.trades << User.new }
  end

  def test_should_have_many_trades
    company = Company.new

    assert company.respond_to?(:trades)

    assert_raise(ActiveRecord::AssociationTypeMismatch) { company.trades << Account.new }
  end

  def test_should_be_considered_invalid_if_it_doesnt_have_a_name_a_best_commission_rate_a_soft_commission_rate_and_credit_rate_when_sent_valid?
    company = Company.new
    assert ! company.valid?
    assert_not_nil company.errors.on(:name)
    assert_not_nil company.errors.on(:best_commission_rate)
    assert_not_nil company.errors.on(:soft_commission_rate)
    assert_not_nil company.errors.on(:credit_rate)

    company = Company.new
    company.name = 'name'
    assert ! company.valid?
    assert_not_nil company.errors.on(:best_commission_rate)
    assert_not_nil company.errors.on(:soft_commission_rate)
    assert_not_nil company.errors.on(:credit_rate)

    company = Company.new
    company.name = 'name'
    company.best_commission_rate = 5.50
    assert ! company.valid?
    assert_not_nil company.errors.on(:soft_commission_rate)
    assert_not_nil company.errors.on(:credit_rate)

    company = Company.new
    company.name = 'name'
    company.soft_commission_rate = 5.50
    assert ! company.valid?
    assert_not_nil company.errors.on(:best_commission_rate)
    assert_not_nil company.errors.on(:credit_rate)

    company = Company.new
    company.name = 'name'
    company.credit_rate = 5.50
    assert ! company.valid?
    assert_not_nil company.errors.on(:best_commission_rate)
    assert_not_nil company.errors.on(:soft_commission_rate)

    company = Company.new
    company.best_commission_rate = 5.50
    company.soft_commission_rate = 5.50
    company.credit_rate = 5.50
    assert ! company.valid?
    assert_not_nil company.errors.on(:name)
  end

  def test_should_be_considered_invalid_if_its_best_commission_rate_soft_commission_rate_and_credit_rate_are_not_numbers_when_sent_valid?
    company = Company.new 
    company.best_commission_rate = 'commission rate'
    assert ! company.valid?
    assert_not_nil company.errors.on(:best_commission_rate)

    company = Company.new 
    company.soft_commission_rate = 'commission rate'
    assert ! company.valid?
    assert_not_nil company.errors.on(:soft_commission_rate)

    company = Company.new
    company.credit_rate = 'credit rate'
    assert ! company.valid?
    assert_not_nil company.errors.on(:credit_rate)

    company = Company.new
    company.name = 'name'
    company.best_commission_rate = 1.2
    company.soft_commission_rate = 1.2
    company.credit_rate = 1.2
    assert company.valid?
  end

  def test_should_say_if_its_current_credit_balance_can_cover_the_given_amount_when_sent_cover?
    Payment.delete_all

    company = companies :company_one

    5.times do 
      company.trades.create! :direction => 'BUY',
        :quantity => 100,
        :symbol => 'MSFT',
        :average_price => 100.0,
        :made_on => Date.today,
        :execution_type => 'SOFT'
    end
    company.reload

    assert company.cover?(0.0)
    assert company.cover?(company.credit_balance - 1)

    assert ! company.cover?(company.credit_balance + 1)
  end

  def test_should_delete_its_trades_users_and_accounts_when_sent_destroy
    assert ! companies(:company_one).users.empty?
    assert ! companies(:company_one).trades.empty?
    assert ! companies(:company_one).accounts.empty?

    assert companies(:company_one).destroy

    assert User.find(:all,
                     :conditions => ['company_id = ?', companies(:company_one).id]).empty?
    assert Trade.find(:all,
                     :conditions => ['company_id = ?', companies(:company_one).id]).empty?
    assert Account.find(:all,
                     :conditions => ['company_id = ?', companies(:company_one).id]).empty?

  end

  def test_should_calculate_the_total_commission_paid_for_all_its_trades_in_the_month_of_the_given_date_to_the_given_date_when_sent_commission_paid_mtd_up_to
    company = companies(:company_one)
    date = 1.month.from_now
    commission_paid = 0

    company.reload
    assert_equal 0, company.commission_paid_mtd_up_to(date)

    trade = Trade.create! :company => company,
      :direction => 'Buy',
      :quantity => 100,
      :symbol => 'IBM',
      :average_price => 10.50,
      :made_on => date,
      :execution_type => 'BEST'
    commission_paid += trade.commission_paid

    trade = Trade.create! :company => company,
      :direction => 'Buy',
      :quantity => 50,
      :symbol => 'MSFT',
      :average_price => 5.0,
      :made_on => date,
      :execution_type => 'SOFT'
    commission_paid += trade.commission_paid

    Trade.create! :company => company,
    :direction => 'Buy',
    :quantity => 100,
    :symbol => 'IBM',
    :average_price => 10.50,
    :made_on => 1.day.from_now(date),
    :execution_type => 'BEST'

    company.reload
    assert_equal commission_paid, company.commission_paid_mtd_up_to(date)
  end

  def test_should_calculate_the_total_commission_paid_for_all_its_trades_in_the_year_of_the_given_date_to_the_given_date_when_sent_commission_paid_ytd_up_to
    company = companies(:company_one)
    date = 1.year.from_now
    commission_paid = 0

    company.reload
    assert_equal 0, company.commission_paid_ytd_up_to(date)

    trade = Trade.create! :company => company,
      :direction => 'Buy',
      :quantity => 100,
      :symbol => 'IBM',
      :average_price => 10.50,
      :made_on => date,
      :execution_type => 'BEST'
    commission_paid += trade.commission_paid

    trade = Trade.create! :company => company,
      :direction => 'Buy',
      :quantity => 50,
      :symbol => 'MSFT',
      :average_price => 5.0,
      :made_on => date,
      :execution_type => 'SOFT'
    commission_paid += trade.commission_paid

    Trade.create! :company => company,
    :direction => 'Buy',
    :quantity => 100,
    :symbol => 'IBM',
    :average_price => 10.50,
    :made_on => 1.day.from_now(date),
    :execution_type => 'BEST'

    company.reload
    assert_equal commission_paid, company.commission_paid_ytd_up_to(date)
  end

  def test_should_calculate_the_total_soft_commission_paid_for_all_its_trades_in_the_month_of_the_given_date_to_the_given_date_when_sent_soft_commission_paid_mtd_up_to
    company = companies(:company_one)
    date = 1.month.from_now
    commission_paid = 0

    company.reload
    assert_equal 0, company.soft_commission_paid_mtd_up_to(date)

    Trade.create! :company => company,
      :direction => 'Buy',
      :quantity => 100,
      :symbol => 'IBM',
      :average_price => 10.50,
      :made_on => date,
      :execution_type => 'BEST'

    trade = Trade.create! :company => company,
      :direction => 'Buy',
      :quantity => 50,
      :symbol => 'MSFT',
      :average_price => 5.0,
      :made_on => date,
      :execution_type => 'SOFT'
    commission_paid += trade.commission_paid

    trade = Trade.create! :company => company,
      :direction => 'Buy',
      :quantity => 50,
      :symbol => 'MSFT',
      :average_price => 5.0,
      :made_on => date,
      :execution_type => 'SOFT'
    commission_paid += trade.commission_paid

    Trade.create! :company => company,
    :direction => 'Buy',
    :quantity => 100,
    :symbol => 'IBM',
    :average_price => 10.50,
    :made_on => 1.day.from_now(date),
    :execution_type => 'SOFT'

    company.reload
    assert_equal commission_paid, company.soft_commission_paid_mtd_up_to(date)
  end

  def test_should_calculate_the_total_soft_commission_paid_for_all_its_trades_in_the_year_of_the_given_date_to_the_given_date_when_sent_soft_commission_paid_ytd_up_to
    company = companies(:company_one)
    date = 1.year.from_now
    commission_paid = 0

    company.reload
    assert_equal 0, company.soft_commission_paid_ytd_up_to(date)

    Trade.create! :company => company,
      :direction => 'Buy',
      :quantity => 100,
      :symbol => 'IBM',
      :average_price => 10.50,
      :made_on => date,
      :execution_type => 'BEST'

    trade = Trade.create! :company => company,
      :direction => 'Buy',
      :quantity => 50,
      :symbol => 'MSFT',
      :average_price => 5.0,
      :made_on => date,
      :execution_type => 'SOFT'
    commission_paid += trade.commission_paid

    trade = Trade.create! :company => company,
      :direction => 'Buy',
      :quantity => 50,
      :symbol => 'MSFT',
      :average_price => 5.0,
      :made_on => date,
      :execution_type => 'SOFT'
    commission_paid += trade.commission_paid

    Trade.create! :company => company,
    :direction => 'Buy',
    :quantity => 100,
    :symbol => 'IBM',
    :average_price => 10.50,
    :made_on => 1.day.from_now(date),
    :execution_type => 'SOFT'

    company.reload
    assert_equal commission_paid, company.soft_commission_paid_ytd_up_to(date)
  end

  def test_should_calculate_the_total_best_commission_paid_for_all_its_trades_in_the_month_of_the_given_date_to_the_given_date_when_sent_best_commission_paid_mtd_up_to
    company = companies(:company_one)
    date = 1.month.from_now
    commission_paid = 0

    company.reload
    assert_equal 0, company.best_commission_paid_mtd_up_to(date)

    trade = Trade.create! :company => company,
      :direction => 'Buy',
      :quantity => 100,
      :symbol => 'IBM',
      :average_price => 10.50,
      :made_on => date,
      :execution_type => 'BEST'
    commission_paid += trade.commission_paid

    trade = Trade.create! :company => company,
      :direction => 'Buy',
      :quantity => 50,
      :symbol => 'MSFT',
      :average_price => 5.0,
      :made_on => date,
      :execution_type => 'BEST'
    commission_paid += trade.commission_paid

    trade = Trade.create! :company => company,
      :direction => 'Buy',
      :quantity => 100,
      :symbol => 'IBM',
      :average_price => 10.50,
      :made_on => date,
      :execution_type => 'AUTO'
    commission_paid += trade.commission_paid

    Trade.create! :company => company,
      :direction => 'Buy',
      :quantity => 50,
      :symbol => 'MSFT',
      :average_price => 5.0,
      :made_on => date,
      :execution_type => 'SOFT'

    Trade.create! :company => company,
      :direction => 'Buy',
      :quantity => 100,
      :symbol => 'IBM',
      :average_price => 10.50,
      :made_on => 1.day.from_now(date),
      :execution_type => 'BEST'

    company.reload
    assert_equal commission_paid, company.best_commission_paid_mtd_up_to(date)
  end

  def test_should_calculate_the_total_best_commission_paid_for_all_its_trades_in_the_year_of_the_given_date_to_the_given_date_when_sent_best_commission_paid_ytd_up_to
    company = companies(:company_one)
    date = 1.year.from_now
    commission_paid = 0

    company.reload
    assert_equal 0, company.best_commission_paid_ytd_up_to(date)

    trade = Trade.create! :company => company,
      :direction => 'Buy',
      :quantity => 100,
      :symbol => 'IBM',
      :average_price => 10.50,
      :made_on => date,
      :execution_type => 'BEST'
    commission_paid += trade.commission_paid

    trade = Trade.create! :company => company,
      :direction => 'Buy',
      :quantity => 50,
      :symbol => 'MSFT',
      :average_price => 5.0,
      :made_on => date,
      :execution_type => 'BEST'
    commission_paid += trade.commission_paid

    trade = Trade.create! :company => company,
      :direction => 'Buy',
      :quantity => 50,
      :symbol => 'MSFT',
      :average_price => 5.0,
      :made_on => date,
      :execution_type => 'AUTO'
    commission_paid += trade.commission_paid

    trade = Trade.create! :company => company,
      :direction => 'Buy',
      :quantity => 50,
      :symbol => 'MSFT',
      :average_price => 5.0,
      :made_on => date,
      :execution_type => 'SOFT'

    Trade.create! :company => company,
      :direction => 'Buy',
      :quantity => 100,
      :symbol => 'IBM',
      :average_price => 10.50,
      :made_on => 1.day.from_now(date),
      :execution_type => 'BEST'

    company.reload
    assert_equal commission_paid, company.best_commission_paid_ytd_up_to(date)
  end

  def test_should_have_many_payments
    company = Company.new

    assert company.respond_to?(:payments)
  end

  def test_should_calculate_the_total_for_all_its_processed_payments_in_the_month_of_the_given_date_up_to_the_given_date_when_sent_processed_payments_mtd_up_to
    Payment.delete_all
    company = companies :company_one
    account = accounts :company_one_vendor_one
    created_on = Time.now
    processed_payments = 0

    company.reload
    assert_equal 0, company.processed_payments_mtd_up_to(created_on)
    5.times do 
      company.trades.create! :direction => 'BUY',
        :quantity => 100,
        :symbol => 'MSFT',
        :average_price => 100.0,
        :made_on => Date.today,
        :execution_type => 'SOFT'
    end
    company.reload
    
    payment = Payment.create! :user => users(:user_one),
      :account => account,
      :amount => 1.0
    invoice = Invoice.create! :number => 1,
      :amount => 1.0,
      :start_date => Date.today,
      :end_date => Date.today,
      :check_number => 1,
      :paid_on => Date.today,
      :payment => payment,
      :created_on => created_on
    processed_payments += payment.amount

    account = accounts :company_one_vendor_two
    payment = Payment.create! :user => users(:user_one),
      :account => account,
      :amount => 1.0
    invoice = Invoice.create! :number => 1,
      :amount => 1.0,
      :start_date => Date.today,
      :end_date => Date.today,
      :check_number => 1,
      :paid_on => Date.today,
      :payment => payment,
      :created_on => created_on
    processed_payments += payment.amount

    payment = Payment.create! :user => users(:user_one),
      :account => account,
      :amount => 1.0

    payment = Payment.create! :user => users(:user_one),
      :account => account,
      :amount => 1.0
    invoice = Invoice.create! :number => 1,
      :amount => 1.0,
      :start_date => Date.today,
      :end_date => Date.today,
      :check_number => 1,
      :paid_on => Date.today,
      :payment => payment,
      :created_on => created_on + 1.day

    company.reload
    assert_equal processed_payments, company.processed_payments_mtd_up_to(created_on)
  end

  def test_should_calculate_the_total_for_all_its_processed_payments_in_the_year_of_the_given_date_up_to_the_given_date_when_sent_processed_payments_ytd_up_to
    Payment.delete_all
    company = companies :company_one
    account = accounts :company_one_vendor_one
    created_on = Time.local(Time.now.year, 2, 1)
    processed_payments = 0

    company.reload
    assert_equal 0, company.processed_payments_ytd_up_to(created_on)
    5.times do 
      company.trades.create! :direction => 'BUY',
        :quantity => 100,
        :symbol => 'MSFT',
        :average_price => 100.0,
        :made_on => Date.today,
        :execution_type => 'SOFT'
    end
    company.reload

    payment = Payment.create! :user => users(:user_one),
      :account => account,
      :amount => 1.0
    invoice = Invoice.create! :number => 1,
      :amount => 1.0,
      :start_date => Date.today,
      :end_date => Date.today,
      :check_number => 1,
      :paid_on => Date.today,
      :payment => payment,
      :created_on => created_on
    processed_payments += payment.amount

    account = accounts :company_one_vendor_two
    payment = Payment.create! :user => users(:user_one),
      :account => account,
      :amount => 1.0
    invoice = Invoice.create! :number => 1,
      :amount => 1.0,
      :start_date => Date.today,
      :end_date => Date.today,
      :check_number => 1,
      :paid_on => Date.today,
      :payment => payment,
      :created_on => created_on - 1.month
    processed_payments += payment.amount

    payment = Payment.create! :user => users(:user_one),
      :account => account,
      :amount => 1.0

    payment = Payment.create! :user => users(:user_one),
      :account => account,
      :amount => 1.0
    invoice = Invoice.create! :number => 1,
      :amount => 1.0,
      :start_date => Date.today,
      :end_date => Date.today,
      :check_number => 1,
      :paid_on => Date.today,
      :payment => payment,
      :created_on => created_on + 1.day

    company.reload
    assert_equal processed_payments, company.processed_payments_ytd_up_to(created_on)
  end

  def test_should_calculate_the_total_for_all_its_pending_and_accepted_payments_in_the_month_of_the_given_date_up_to_the_given_date_when_sent_pending_and_accepted_payments_mtd_up_to
    company = companies :company_one
    company.payments.each {|each| each.destroy}

    account = accounts :company_one_vendor_one
    pending_and_accepted_payments = 0

    company.reload
    assert_equal 0, company.pending_and_accepted_payments_mtd_up_to(Time.now)
    5.times do 
      company.trades.create! :direction => 'BUY',
        :quantity => 100,
        :symbol => 'MSFT',
        :average_price => 100.0,
        :made_on => Date.today,
        :execution_type => 'SOFT'
    end
    company.reload

    payment = Payment.create! :user => users(:user_one),
      :account => account,
      :amount => 1.0
    pending_and_accepted_payments += payment.amount

    account = accounts :company_one_vendor_two
    payment = Payment.create! :user => users(:user_one),
      :account => account,
      :amount => 1.0
    assert payment.update_attribute(:status, 'Accepted')
    pending_and_accepted_payments += payment.amount

    payment = Payment.create! :user => users(:user_one),
      :account => account,
      :amount => 1.0
    assert payment.update_attribute(:status, 'Rejected')

    payment = Payment.create! :user => users(:user_one),
      :account => account,
      :amount => 1.0,
      :created_on => 1.month.from_now

    payment = Payment.create! :user => users(:user_one),
      :account => account,
      :amount => 1.0
    Invoice.create! :number => 1,
      :amount => 1.0,
      :start_date => Date.today,
      :end_date => Date.today,
      :check_number => 1,
      :paid_on => Date.today,
      :payment => payment

    company.reload
    assert_equal pending_and_accepted_payments, company.pending_and_accepted_payments_mtd_up_to(Time.now)
  end

  def test_should_calculate_the_total_for_all_its_pending_and_accepted_payments_in_the_year_of_the_given_date_up_to_the_given_date_when_sent_pending_and_accepted_payments_ytd_up_to
    company = companies :company_one
    company.payments.each {|each| each.destroy}

    account = accounts :company_one_vendor_one
    pending_and_accepted_payments = 0
    created_on = Time.local Time.now.year, 2, 1

    company.reload
    assert_equal 0, company.pending_and_accepted_payments_ytd_up_to(created_on)
    5.times do 
      company.trades.create! :direction => 'BUY',
        :quantity => 100,
        :symbol => 'MSFT',
        :average_price => 100.0,
        :made_on => Date.today,
        :execution_type => 'SOFT'
    end
    company.reload

    payment = Payment.create! :user => users(:user_one),
      :account => account,
      :amount => 1.0,
      :created_on => created_on
    pending_and_accepted_payments += payment.amount

    account = accounts :company_one_vendor_two
    payment = Payment.create! :user => users(:user_one),
      :account => account,
      :amount => 1.0,
      :created_on => created_on - 1.month
    assert payment.update_attribute(:status, 'Accepted')
    pending_and_accepted_payments += payment.amount

    payment = Payment.create! :user => users(:user_one),
      :account => account,
      :amount => 1.0,
      :created_on => created_on 
    assert payment.update_attribute(:status, 'Rejected')

    payment = Payment.create! :user => users(:user_one),
      :account => account,
      :amount => 1.0,
      :created_on => created_on + 1.day

    payment = Payment.create! :user => users(:user_one),
      :account => account,
      :amount => 1.0
    Invoice.create! :number => 1,
      :amount => 1.0,
      :start_date => Date.today,
      :end_date => Date.today,
      :check_number => 1,
      :paid_on => Date.today,
      :payment => payment

    company.reload
    assert_equal pending_and_accepted_payments, company.pending_and_accepted_payments_ytd_up_to(created_on)
  end

  def test_should_calculate_the_total_credits_accrued_in_the_month_of_the_given_date_to_the_given_date_when_sent_credits_accrued_mtd_up_to
    company = companies :company_one
    company.trades.each {|each| each.destroy}

    date = Time.now
    credit_accrued = 0

    company.reload
    assert_equal 0, company.credits_accrued_mtd_up_to(date)

    trade = Trade.create! :company => company,
      :direction => 'Buy',
      :quantity => 100,
      :symbol => 'IBM',
      :average_price => 10.50,
      :made_on => date,
      :execution_type => 'SOFT'
    credit_accrued += trade.credit_accrued

    trade = Trade.create! :company => company,
      :direction => 'Buy',
      :quantity => 50,
      :symbol => 'MSFT',
      :average_price => 5.0,
      :made_on => date,
      :execution_type => 'SOFT'
    credit_accrued += trade.credit_accrued

    Trade.create! :company => company,
      :direction => 'Buy',
      :quantity => 50,
      :symbol => 'MSFT',
      :average_price => 5.0,
      :made_on => date,
      :execution_type => 'BEST'

    Trade.create! :company => company,
      :direction => 'Buy',
      :quantity => 50,
      :symbol => 'MSFT',
      :average_price => 5.0,
      :made_on => date + 1.day,
      :execution_type => 'BEST'

    company.reload
    assert_equal credit_accrued, company.credits_accrued_mtd_up_to(date)
  end

  def test_should_calculate_the_total_credits_accrued_in_the_year_of_the_given_date_to_the_given_date_when_sent_credits_accrued_ytd_up_to
    company = companies :company_one
    company.trades.each {|each| each.destroy}

    date = Time.local Time.now.year, 2, 1
    credit_accrued = 0

    company.reload
    assert_equal 0, company.credits_accrued_ytd_up_to(date)

    trade = Trade.create! :company => company,
      :direction => 'Buy',
      :quantity => 100,
      :symbol => 'IBM',
      :average_price => 10.50,
      :made_on => date,
      :execution_type => 'SOFT'
    credit_accrued += trade.credit_accrued

    trade = Trade.create! :company => company,
      :direction => 'Buy',
      :quantity => 50,
      :symbol => 'MSFT',
      :average_price => 5.0,
      :made_on => date - 1.month,
      :execution_type => 'SOFT'
    credit_accrued += trade.credit_accrued

    Trade.create! :company => company,
      :direction => 'Buy',
      :quantity => 50,
      :symbol => 'MSFT',
      :average_price => 5.0,
      :made_on => date + 1.day,
      :execution_type => 'BEST'

    Trade.create! :company => company,
      :direction => 'Buy',
      :quantity => 50,
      :symbol => 'MSFT',
      :average_price => 5.0,
      :made_on => date - 1.year,
      :execution_type => 'BEST'

    company.reload
    assert_equal credit_accrued, company.credits_accrued_ytd_up_to(date)
  end

  def test_should_have_many_vendors
    company = companies :company_one
    vendors = company.vendors

    assert ! vendors.empty?
    assert vendors.all? {|each| each.vendor?}
  end    

  def test_should_have_many_brokers
    company = companies :company_two
    brokers = company.brokers

    assert ! brokers.empty?
    assert brokers.all? {|each| each.broker?}
  end

  def test_should_calculate_the_year_prior_to_the_given_years_credit_accrued_when_sent_prior_year_credits_accrued
    company = companies :company_one
    company.payments.each {|each| each.destroy}
    company.trades.each {|each| each.destroy}
    credits_accrued = 0

    company.reload
    assert_equal 0, company.prior_year_credits_accrued(Time.now)
    5.times do 
      company.trades.create! :direction => 'BUY',
        :quantity => 100,
        :symbol => 'MSFT',
        :average_price => 100.0,
        :made_on => Date.today,
        :execution_type => 'SOFT'
    end
    company.reload
    credits_accrued = company.prior_year_credits_accrued(Time.now)

    payment = Payment.create! :user => users(:user_one),
      :account => accounts(:company_one_vendor_one),
      :amount => 1.00,
      :created_on => 1.year.ago
    credits_accrued -= payment.amount

    payment = Payment.create! :user => users(:user_one),
      :account => accounts(:company_one_vendor_one),
      :amount => 1.00
    assert payment.update_attributes(:status => 'Processed',
                                     :processed_on => 1.year.ago)
    credits_accrued -= payment.amount

    payment = Payment.create! :user => users(:user_one),
      :account => accounts(:company_one_vendor_one),
      :amount => 1.00

    payment = Payment.create! :user => users(:user_one),
      :account => accounts(:company_one_vendor_one),
      :amount => 1.00
    assert payment.update_attributes(:status => 'Processed',
                                     :processed_on => Time.now)

    trade = Trade.create! :direction => 'sell',
      :quantity => 1,
      :symbol => 'abc',
      :average_price => 1.0,
      :made_on => 1.year.ago,
      :execution_type => 'SOFT',
      :company => company
    credits_accrued += trade.credit_accrued

    Trade.create! :direction => 'sell',
      :quantity => 1,
      :symbol => 'abc',
      :average_price => 1.0,
      :made_on => Time.now,
      :execution_type => 'SOFT',
      :company => company

    company.reload
    assert_equal credits_accrued, company.prior_year_credits_accrued(Time.now)
  end

  def test_should_calculate_the_total_credits_accrued_in_the_month_of_the_given_date_to_the_given_date_when_sent_total_credits_accrued_mtd_up_to
    company = companies :company_one
    company.trades.each {|each| each.destroy}

    date = Time.now
    credit_accrued = 0

    company.reload
    assert_equal 0, company.total_credits_accrued_mtd_up_to(date)

    trade = Trade.create! :company => company,
      :direction => 'Buy',
      :quantity => 100,
      :symbol => 'IBM',
      :average_price => 10.50,
      :made_on => date,
      :execution_type => 'SOFT'
    credit_accrued += trade.credit_accrued

    trade = Trade.create! :company => company,
      :direction => 'Buy',
      :quantity => 50,
      :symbol => 'MSFT',
      :average_price => 5.0,
      :made_on => date,
      :execution_type => 'SOFT'
    credit_accrued += trade.credit_accrued

    Trade.create! :company => company,
      :direction => 'Buy',
      :quantity => 50,
      :symbol => 'MSFT',
      :average_price => 5.0,
      :made_on => date,
      :execution_type => 'BEST'

    Trade.create! :company => company,
      :direction => 'Buy',
      :quantity => 50,
      :symbol => 'MSFT',
      :average_price => 5.0,
      :made_on => date + 1.day,
      :execution_type => 'BEST'

    company.reload
    assert_equal credit_accrued, company.total_credits_accrued_mtd_up_to(date)
  end

  def test_should_calculate_the_total_credits_accrued_up_to_the_given_date_when_sent_total_credits_accrued_up_to
    company = companies :company_one
    company.payments.each {|each| each.destroy}
    company.trades.each {|each| each.destroy}
    credits_accrued = 0

    company.reload
    assert_equal 0, company.total_credits_accrued_up_to(Time.now)
    5.times do 
      company.trades.create! :direction => 'BUY',
        :quantity => 100,
        :symbol => 'MSFT',
        :average_price => 100.0,
        :made_on => Date.today,
        :execution_type => 'SOFT'
    end
    company.reload
    credits_accrued = company.total_credits_accrued_up_to(Time.now)

    payment = Payment.create! :user => users(:user_one),
      :account => accounts(:company_one_vendor_one),
      :amount => 1.00,
      :created_on => 1.year.ago
    credits_accrued -= payment.amount

    payment = Payment.create! :user => users(:user_one),
      :account => accounts(:company_one_vendor_one),
      :amount => 1.00
    assert payment.update_attributes(:status => 'Processed',
                                     :processed_on => 1.year.ago)
    credits_accrued -= payment.amount

    payment = Payment.create! :user => users(:user_one),
      :account => accounts(:company_one_vendor_one),
      :amount => 1.00

    payment = Payment.create! :user => users(:user_one),
      :account => accounts(:company_one_vendor_one),
      :amount => 1.00
    assert payment.update_attributes(:status => 'Processed',
                                     :processed_on => Time.now)

    trade = Trade.create! :direction => 'sell',
      :quantity => 1,
      :symbol => 'abc',
      :average_price => 1.0,
      :made_on => 1.year.ago,
      :execution_type => 'SOFT',
      :company => company
    credits_accrued += trade.credit_accrued

    trade = Trade.create! :direction => 'sell',
      :quantity => 1,
      :symbol => 'abc',
      :average_price => 1.0,
      :made_on => Time.now,
      :execution_type => 'SOFT',
      :company => company
    credits_accrued += trade.credit_accrued

    company.reload
    assert_equal credits_accrued, company.total_credits_accrued_up_to(Time.now)
  end

  def test_should_calculate_the_credit_balance_in_the_given_month_up_to_the_given_date_when_sent_credit_balance_mtd_up_to
    company = companies :company_one

    company.payments.each {|each| each.destroy}
    company.trades.each {|each| each.destroy}
    credits_accrued = 0

    company.reload
    assert_equal 0, company.credit_balance_mtd_up_to(Time.now)
    5.times do 
      company.trades.create! :direction => 'BUY',
        :quantity => 100,
        :symbol => 'MSFT',
        :average_price => 100.0,
        :made_on => Date.today,
        :execution_type => 'SOFT'
    end

    company.reload
    credits_accrued = company.credits_accrued_mtd_up_to(Time.now)

    payment = Payment.create! :user => users(:user_one),
      :account => accounts(:company_one_vendor_one),
      :amount => 1.00,
      :created_on => Time.now.beginning_of_month
    credits_accrued -= payment.amount

    payment = Payment.create! :user => users(:user_one),
      :account => accounts(:company_one_vendor_one),
      :amount => 1.00
    assert payment.update_attributes(:status => 'Processed',
                                     :processed_on => Time.now.beginning_of_month)
    credits_accrued -= payment.amount

    payment = Payment.create! :user => users(:user_one),
      :account => accounts(:company_one_vendor_one),
      :amount => 1.00,
      :created_on => 1.month.ago

    payment = Payment.create! :user => users(:user_one),
      :account => accounts(:company_one_vendor_one),
      :amount => 1.00
    assert payment.update_attributes(:status => 'Processed',
                                     :processed_on => 1.month.ago)

    trade = Trade.create! :direction => 'sell',
      :quantity => 1,
      :symbol => 'abc',
      :average_price => 1.0,
      :made_on => Time.now.beginning_of_month,
      :execution_type => 'SOFT',
      :company => company
    credits_accrued += trade.credit_accrued

    trade = Trade.create! :direction => 'sell',
      :quantity => 1,
      :symbol => 'abc',
      :average_price => 1.0,
      :made_on => Time.now.beginning_of_month,
      :execution_type => 'SOFT',
      :company => company
    credits_accrued += trade.credit_accrued

    company.reload
    assert_equal credits_accrued.to_f, company.credit_balance_mtd_up_to(Time.now).to_f
  end

  def test_should_calculate_the_credit_balance_up_to_the_given_date_when_sent_credit_balance_up_to
    company = companies :company_one

    company.payments.each {|each| each.destroy}
    company.trades.each {|each| each.destroy}
    credits_accrued = 0

    company.reload
    assert_equal 0, company.credit_balance_up_to(Time.now)
    5.times do 
      company.trades.create! :direction => 'BUY',
        :quantity => 100,
        :symbol => 'MSFT',
        :average_price => 100.0,
        :made_on => Date.today,
        :execution_type => 'SOFT'
    end
    company.reload
    credits_accrued = company.credit_balance_up_to(Time.now)

    payment = Payment.create! :user => users(:user_one),
      :account => accounts(:company_one_vendor_one),
      :amount => 1.00,
      :created_on => 1.day.ago
    credits_accrued -= payment.amount

    payment = Payment.create! :user => users(:user_one),
      :account => accounts(:company_one_vendor_one),
      :amount => 1.00
    assert payment.update_attributes(:status => 'Processed',
                                     :processed_on => 1.year.ago)
    credits_accrued -= payment.amount

    payment = Payment.create! :user => users(:user_one),
      :account => accounts(:company_one_vendor_one),
      :amount => 1.00,
      :created_on => 1.day.from_now

    payment = Payment.create! :user => users(:user_one),
      :account => accounts(:company_one_vendor_one),
      :amount => 1.00
    assert payment.update_attributes(:status => 'Processed',
                                     :processed_on => 1.day.from_now)

    trade = Trade.create! :direction => 'sell',
      :quantity => 1,
      :symbol => 'abc',
      :average_price => 1.0,
      :made_on => Time.now,
      :execution_type => 'SOFT',
      :company => company
    credits_accrued += trade.credit_accrued

    trade = Trade.create! :direction => 'sell',
      :quantity => 1,
      :symbol => 'abc',
      :average_price => 1.0,
      :made_on => 1.day.from_now,
      :execution_type => 'SOFT',
      :company => company

    company.reload
    assert_equal credits_accrued, company.credit_balance_up_to(Time.now)
  end

  def test_should_have_many_organizations
    company = Company.new

    assert company.respond_to?(:organizations)
  end

  def test_should_calculate_its_current_balance_when_sent_credit_balance
    Payment.delete_all
    Trade.delete_all

    company = companies :company_one
    assert_equal 0, company.credit_balance

    credit_balance = 0
    5.times do |each|
      trade = Trade.create! :direction => 'BUY',
        :quantity => 100,
        :symbol => 'MSFT',
        :average_price => 100.0,
        :made_on => each.years.ago,
        :execution_type => 'SOFT',
        :company => company
      credit_balance += trade.credit_accrued
    end
    assert_equal credit_balance, company.credit_balance

    Payment.create! :user => users(:user_one),
      :account => accounts(:company_one_vendor_one),
      :amount => 1.00

    payment = Payment.create! :user => users(:user_one),
      :account => accounts(:company_one_vendor_one),
      :amount => 1.00
    assert payment.update_attributes(:status => 'Processed',
                                     :processed_on => 1.day.ago)
    credit_balance -= payment.amount

    company.reload
    assert_equal credit_balance, company.credit_balance
  end

end
