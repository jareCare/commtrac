require File.dirname(__FILE__) + '/../test_helper'

class InvoiceTest < Test::Unit::TestCase

  fixtures :invoices, 
    :companies, 
    :accounts,
    :payments, 
    :users,
    :organizations

  def test_should_be_associated_with_a_payment
    invoice = Invoice.new
    
    assert invoice.respond_to?(:payment)

    assert_raise(ActiveRecord::AssociationTypeMismatch) { invoice.payment = User.new }
  end

  def test_should_have_one_picture
    invoice = Invoice.new

    assert invoice.respond_to?(:picture)

    assert_raise(ActiveRecord::AssociationTypeMismatch) { invoice.picture = User.new }
  end

  def test_should_find_all_invoices_made_to_a_given_vendor_when_sent_search
    results = Invoice.search(companies(:company_one), 
                             :vendors => [organizations(:vendor_one)],
                             :time_span => 1.week.ago..Time.now)

    assert_not_equal Invoice.find(:all), (Invoice.find(:all) - results)
    results.each do |each|
      assert companies(:company_one).accounts.include?(each.payment.account)
      assert_equal organizations(:vendor_one), each.payment.account.organization
      assert ! each.payment.account.organization.broker?
    end
  end

  def test_should_find_all_invoices_paid_within_the_given_time_span_to_the_given_vendor_when_sent_search
    results = Invoice.search companies(:company_one), 
    :time_span => (1.month.ago.to_date)..(1.month.from_now.to_date),
    :vendors => [organizations(:vendor_one)]

    assert_not_equal Invoice.find(:all), (Invoice.find(:all) - results)
    results.each do |each|
      assert companies(:company_one).accounts.include?(each.payment.account)
      assert ((1.month.ago.to_date)..(1.month.from_now.to_date)).include?(each.paid_on)
      assert_equal organizations(:vendor_one), each.payment.account.organization
      assert ! each.payment.account.organization.broker?
    end
  end

  def test_should_return_an_empty_array_if_the_company_does_not_have_any_accounts_when_sent_search
    company = Company.new :name => 'name', 
    :best_commission_rate => '5.50',
    :soft_commission_rate => '5.50',
    :credit_rate => '10.00'
    assert company.save

    invoices = Invoice.search company, 
    :time_span => (1.month.ago.to_date)..(Date.today)
    assert invoices.empty?
  end

  def test_should_be_considered_invalid_if_it_is_missing_any_attribute_when_sent_valid?
    invoice = Invoice.new
    assert ! invoice.valid?

    invoice = Invoice.new
    invoice.number = 'number'
    assert ! invoice.valid?

    invoice = Invoice.new
    invoice.amount = 5.50
    assert ! invoice.valid?

    invoice = Invoice.new
    invoice.start_date = Date.today
    assert ! invoice.valid?

    invoice = Invoice.new
    invoice.end_date = Date.today
    assert ! invoice.valid?

    invoice = Invoice.new
    invoice.check_number = 5
    assert ! invoice.valid?
    
    invoice = Invoice.new
    invoice.paid_on = Date.today
    assert ! invoice.valid?

    invoice = Invoice.new
    invoice.payment = payments(:user_two_company_one_vendor_one_account)
    assert ! invoice.valid?
  end

  def test_should_be_considered_invalid_if_its_amount_is_not_a_number_when_sent_valid?
    invoices(:company_one_vendor_one_this_month).amount = 'amount'
    assert ! invoices(:company_one_vendor_one_this_month).valid?

    invoices(:company_one_vendor_one_this_month).amount = 2.00
    invoices(:company_one_vendor_one_this_month).valid?
  end

  def test_should_be_considered_invalid_if_the_company_the_payment_is_for_doesnt_have_enough_credit_balance_to_cover_its_amount_when_sent_save
    invoice = Invoice.new
    invoice.number = 'A-1'
    invoice.amount = accounts(:company_one_vendor_one).company.credit_balance + 1
    invoice.start_date = 1.day.ago.to_date
    invoice.end_date = Time.now.to_date
    invoice.check_number = 'A123'
    invoice.paid_on = Time.now.to_date
    invoice.payment = payments :user_two_company_one_vendor_one_account

    assert ! invoice.save
    assert_not_nil invoice.errors.on(:amount)
  end

  def test_should_be_considered_invalid_if_its_end_date_comes_before_its_start_date_when_sent_save
    invoice = Invoice.new
    invoice.number = '22'
    invoice.amount = 5.50
    invoice.check_number = '34'
    invoice.paid_on = Time.now.to_date
    invoice.payment = payments :user_two_company_one_vendor_one_account
    invoice.start_date = Time.now.to_date
    invoice.end_date = Time.now.yesterday.to_date

    assert ! invoice.valid?
    assert_not_nil invoice.errors.on_base
  end

  def test_should_be_considered_invalid_with_a_negative_amount_when_sent_valid?
    invoice = Invoice.new
    invoice.number = '22'
    invoice.amount = -5.50
    invoice.check_number = '34'
    invoice.paid_on = Time.now.to_date
    invoice.payment = payments :user_two_company_one_vendor_one_account
    invoice.start_date = Time.now.to_date
    invoice.end_date = 1.day.from_now.to_date

    assert ! invoice.valid?
    assert_not_nil invoice.errors.on(:amount)

    invoice.amount = 0.0
    assert ! invoice.valid?
    assert_not_nil invoice.errors.on(:amount)
  end

  def test_should_find_all_invoices_whos_payments_accounts_vendor_is_a_broker_with_the_given_id_when_sent_search
    results = Invoice.search(companies(:company_two),
                             :brokers => [organizations(:broker_one)],
                             :time_span => 1.day.ago..Time.now)

    assert_not_equal Invoice.find(:all), (Invoice.find(:all) - results)
    results.each do |each|
      assert each.payment.account.organization.broker?
    end
  end

  def test_should_find_all_invoices_whos_payments_accounts_vendor_is_a_broker_or_vendor_with_the_given_ids_when_sent_search
    results = Invoice.search(companies(:company_two),
                             :brokers => [organizations(:broker_one)],
                             :vendors => [organizations(:vendor_one)],
                             :time_span => 1.day.ago..Time.now)

    assert_not_equal Invoice.find(:all), (Invoice.find(:all) - results)
    results.each do |each|
      assert each.payment.account.organization.broker? ||
        each.payment.account.organization.vendor?
    end
  end

  def test_should_find_all_invoices_from_all_the_companys_accounts_with_the_given_vendors_and_brokers_when_sent_search
    results = Invoice.search(companies(:company_two),
                             :brokers => [organizations(:broker_one)],
                             :vendors => [],
                             :time_span => 1.day.ago..Time.now)

    assert_not_equal Invoice.find(:all), (Invoice.find(:all) - results)
    results.each do |each|
      assert_equal organizations(:broker_one), each.payment.account.organization
    end

    results = Invoice.search(companies(:company_two),
                             :brokers => [],
                             :vendors => [organizations(:vendor_one)],
                             :time_span => 1.year.ago..Time.now)

    assert_not_equal Invoice.find(:all), (Invoice.find(:all) - results)
    results.each do |each|
      assert_equal organizations(:vendor_one), each.payment.account.organization
    end

    results = Invoice.search(companies(:company_two),
                             :brokers => [organizations(:broker_one)],
                             :vendors => [organizations(:vendor_one)],
                             :time_span => 1.day.ago..Time.now)

    assert_not_equal Invoice.find(:all), (Invoice.find(:all) - results)
    results.each do |each|
      assert organizations(:vendor_one) == each.payment.account.organization ||
        organizations(:broker_one) == each.payment.account.organization
    end
  end

  def test_should_be_considered_invalid_if_its_amount_is_more_than_its_payment_amount_when_sent_save
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
    payment = Payment.create! :user => users(:user_one),
    :account => accounts(:company_one_vendor_one),
    :amount => 1.00

    invoice = Invoice.new :number => 1,
    :amount => payment.amount + 1,
    :start_date => 1.month.ago.to_date,
    :end_date => Date.today,
    :check_number => 'A-1',
    :paid_on => Date.today,
    :payment => payment

    assert ! invoice.save
    assert_not_nil invoice.errors.on(:amount)
  end

  def test_should_mark_its_payment_as_processed_and_set_its_processed_on_date_if_it_pays_off_the_entire_payment_when_sent_save_on_create
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

    payment = Payment.create! :user => users(:user_one),
      :account => accounts(:company_one_vendor_one),
      :amount => 2.00
  
    Invoice.create! :number => 1,
      :amount => payment.amount - 1,
      :start_date => 1.month.ago.to_date,
      :end_date => Date.today,
      :check_number => 'A-1',
      :paid_on => Date.today,
      :payment => payment

    payment.reload
    assert_nil payment.processed_on

    Invoice.create! :number => 2,
      :amount => 1,
      :start_date => 1.month.ago.to_date,
      :end_date => Date.today,
      :check_number => 'A-2',
      :paid_on => Date.today,
      :payment => payment

    payment.reload
    assert payment.processed?
    assert_not_nil payment.processed_on
    assert_equal Date.today, payment.processed_on
  end

end
