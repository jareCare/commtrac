require File.dirname(__FILE__) + '/../test_helper'

class PaymentTest < Test::Unit::TestCase

  fixtures :users, 
    :companies, 
    :trades,
    :accounts, 
    :pictures,
    :payments,
    :organizations

  def setup
    ActionMailer::Base.deliveries.clear
  end

  def test_should_be_associated_with_a_user
    payment = Payment.new

    assert payment.respond_to?(:user)

    assert_raise(ActiveRecord::AssociationTypeMismatch) { payment.user = Account.new }
  end

  def test_should_be_associated_with_an_account
    payment = Payment.new

    assert payment.respond_to?(:account)

    assert_raise(ActiveRecord::AssociationTypeMismatch) { payment.account = User.new }
  end

  def test_should_have_many_invoices
    payment = Payment.new

    assert payment.respond_to?(:invoices)

    assert_raise(ActiveRecord::AssociationTypeMismatch) { payment.invoices << User.new }
  end

  def test_should_be_considered_invalid_if_it_isnt_associated_with_a_user_when_sent_valid?
    payment = Payment.new

    assert ! payment.valid?
    assert_not_nil payment.errors.on(:user)
  end

  def test_should_be_considered_invalid_if_it_isnt_associated_with_an_account_when_sent_valid?
    payment = Payment.new

    assert ! payment.valid?
    assert_not_nil payment.errors.on(:account)
  end

  def test_should_be_considered_invalid_if_it_doesnt_have_an_amount_when_sent_valid?
    payment = Payment.new
    payment.account = accounts(:company_one_vendor_one)
    payment.user = users(:user_two)

    assert ! payment.valid?
    assert_not_nil payment.errors.on(:amount)
  end

  def test_should_be_considered_invalid_if_its_amount_is_not_a_number_when_sent_valid?
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

    payment = Payment.new :user => users(:user_one),
      :account => accounts(:company_one_vendor_one)
    payment.amount = 'amount'

    assert ! payment.valid?
    assert_not_nil payment.errors.on(:amount)

    payment.amount = 0.50
    assert payment.valid?
  end

  def test_should_be_considered_invalid_if_its_users_company_cant_cover_the_bpayment_amount_when_sent_save
    payment = Payment.new :user => users(:user_one),
    :account => accounts(:company_one_vendor_one),
    :amount => accounts(:company_one_vendor_one).company.credit_balance + 1

    assert ! payment.save
    assert_not_nil payment.errors.on_base
  end

  def test_should_be_considered_invalid_with_a_negative_amount_when_sent_valid?
    payment = Payment.new :user => users(:user_one),
    :account => accounts(:company_one_vendor_one),
    :amount => -5.0

    assert ! payment.valid?
    assert_not_nil payment.errors.on(:amount)

    payment.amount = 0
    assert ! payment.valid?
    assert_not_nil payment.errors.on(:amount)
  end

  def test_should_create_a_pdf_of_itself_for_the_given_reasons_when_sent_to_pdf
    PDF::Writer.any_instance.expects(:image)

    payment = Payment.new :user => users(:user_two),
    :account => accounts(:company_one_vendor_one),
    :amount => 100.00,
    :reasons => ['research', 'work']

    pdf = payment.to_pdf
    assert_kind_of PDF::Writer, pdf
    assert_match /#{payment.amount}/, pdf.to_s
    assert_match /#{payment.account.company.name}/, pdf.to_s
    assert_match /#{payment.account.organization.name}/, pdf.to_s
    assert_match /research/, pdf.to_s
    assert_match /work/, pdf.to_s
  end

  def test_should_not_add_the_users_picture_to_the_pdf_of_itself_if_the_user_doesnt_have_one_when_sent_to_pdf
    picture = mock
    picture.expects(:nil?).returns true
    User.any_instance.expects(:picture).returns picture

    payment = Payment.new :user => users(:user_two),
    :account => accounts(:company_one_vendor_one),
    :amount => 100.00,
    :reasons => ['research', 'work']

    pdf = payment.to_pdf

    assert_kind_of PDF::Writer, pdf
    assert_match /#{payment.amount}/, pdf.to_s
    assert_match /#{payment.account.company.name}/, pdf.to_s
    assert_match /#{payment.account.organization.name}/, pdf.to_s
    assert_match /research/, pdf.to_s
    assert_match /research/, pdf.to_s
    assert_match /work/, pdf.to_s    
  end

  def test_should_return_the_difference_between_its_amount_and_the_total_amount_of_all_its_payments_when_sent_amount_due
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

    payment = Payment.create! :user => users(:user_one),
    :account => accounts(:company_one_vendor_one),
    :amount => 1.00

    assert_equal 1.00, payment.amount_due

    invoice = payment.invoices.create! :number => 1,
    :amount => 0.50,
    :start_date => 1.month.ago.to_date,
    :end_date => Date.today,
    :check_number => 'A-1',
    :paid_on => Date.today,
    :payment => payment

    payment.reload
    assert_equal 0.50, payment.amount_due
  end

  def test_should_say_if_its_been_paid_off_when_sent_paid_off?
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

    payment = Payment.create! :user => users(:user_one),
      :account => accounts(:company_one_vendor_one),
      :amount => 1.00
    assert ! payment.paid_off?

    Invoice.create! :number => 1,
      :amount => 1.00,
      :start_date => 1.month.ago.to_date,
      :end_date => Date.today,
      :check_number => 'A-1',
      :paid_on => Date.today,
      :payment => payment

    payment.reload
    assert payment.paid_off?
  end

  def test_should_delete_its_invoices_when_sent_destroy
    assert ! payments(:user_two_company_one_vendor_one_account).invoices.empty?

    assert payments(:user_two_company_one_vendor_one_account).destroy

    assert Invoice.find(:all,
                        :conditions => ['payment_id = ?', payments(:user_two_company_one_vendor_one_account).id]).empty?
  end

  def test_should_set_its_status_to_pending_when_sent_save_on_create
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

    payment = Payment.create! :user => users(:user_one),
      :account => accounts(:company_one_vendor_one),
      :amount => 1.00
    assert payment.pending?
  end

  def test_should_say_if_its_accepted_when_sent_accepted?
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

    payment = Payment.create! :user => users(:user_one),
      :account => accounts(:company_one_vendor_one),
      :amount => 1.00
    assert ! payment.accepted?

    assert payment.update_attribute(:status, 'Accepted')
    assert payment.accepted?
  end

  def test_should_say_if_its_been_processed_when_sent_processed?
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

    payment = Payment.create! :user => users(:user_one),
      :account => accounts(:company_one_vendor_one),
      :amount => 1.00
    assert ! payment.processed?

    assert payment.update_attribute(:status, 'Processed')
    assert payment.processed?
  end

  def test_should_say_if_its_been_rejected_when_sent_rejected?
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

    payment = Payment.create! :user => users(:user_one),
      :account => accounts(:company_one_vendor_one),
      :amount => 1.00
    assert ! payment.rejected?

    assert payment.update_attribute(:status, 'Rejected')
    assert payment.rejected?
  end

  def test_should_update_its_status_to_accepted_and_send_a_payment_accepted_email_when_sent_accept!
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

    payment = Payment.create! :user => users(:user_one),
      :account => accounts(:company_one_vendor_one),
      :amount => 1.00
    ActionMailer::Base.deliveries.clear
    assert ActionMailer::Base.deliveries.empty?
    payment.accept!
    assert payment.accepted?
    assert ! ActionMailer::Base.deliveries.empty?
    assert_match /payment accepted/i, ActionMailer::Base.deliveries[0].subject
  end

  def test_should_update_its_status_to_rejected_and_send_a_payment_rejected_email_when_sent_reject!
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

    payment = Payment.create! :user => users(:user_one),
      :account => accounts(:company_one_vendor_one),
      :amount => 1.00
    ActionMailer::Base.deliveries.clear
    payment.reject!
    assert payment.rejected?
    assert ! ActionMailer::Base.deliveries.empty?
    assert_match /payment rejected/i, ActionMailer::Base.deliveries[0].subject
  end

  def test_should_send_a_payment_cancellation_email_when_sent_destroy
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

    payment = Payment.create! :user => users(:user_one),
      :account => accounts(:company_one_vendor_one),
      :amount => 1.00
    ActionMailer::Base.deliveries.clear
    assert ActionMailer::Base.deliveries.empty?
    payment.destroy
    assert ! ActionMailer::Base.deliveries.empty?
    assert_match /payment cancelled/i, ActionMailer::Base.deliveries[0].subject
  end

  def test_should_send_a_payment_request_email_when_sent_save_on_create
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

    assert ActionMailer::Base.deliveries.empty?
    payment = Payment.create! :user => users(:user_one),
      :account => accounts(:company_one_vendor_one),
      :amount => 1.00,
      :reasons => ['one', 'two']
    assert ! ActionMailer::Base.deliveries.empty?
    assert_match /payment request/i, ActionMailer::Base.deliveries[0].subject
  end

end
