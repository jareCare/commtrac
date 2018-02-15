require File.dirname(__FILE__) + '/../test_helper'
require 'payments_controller'

# Re-raise errors caught by the controller.
class PaymentsController; def rescue_action(e) raise e end; end

class PaymentsControllerTest < Test::Unit::TestCase

  fixtures :users, 
    :accounts, 
    :companies,
    :organizations, 
    :payments

  def setup
    @controller = PaymentsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    ActionMailer::Base.deliveries.clear
  end

  def test_should_create_a_new_payment_object_on_GET_to_new
    assert_recognizes({ :controller => 'payments',
                        :action => 'new',
                        :company_id => '1' },
                      :path => 'companies/1/payments/new', :method => :get)

    get :new, {
      :company_id => users(:user_two).company.id,
    }, :user_id => users(:user_two).id

    assert_equal users(:user_two).company, assigns(:company)
    assert_kind_of Payment, assigns(:payment)
    assert_response :success
    assert_template 'new'
  end

  def test_should_create_a_new_payment_record_and_send_an_email_on_POST_to_create
    assert_recognizes({ :controller => 'payments',
                        :action => 'create',
                        :company_id => '1' },
                      :path => 'companies/1/payments', :method => :post)

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

    PDF::Writer.any_instance.expects(:image)

    post :create, { 
      :company_id => users(:user_two).company.id,
      :payment => { 
        :amount => 0.50, 
        :account_id => accounts(:company_one_vendor_one).id,
        :request => 'Notes' 
      },
      'work' => '1',
      'research' => '1',
      'other' => '1',
      'other_description' => 'other_description' 
    }, :user_id => users(:user_two).id

    assert_equal users(:user_two).company, assigns(:company)
    assert Payment.find(:first,
                        :conditions => ['amount = ? 
                                         and user_id = ? 
                                         and account_id = ?',
                                        0.50, 
                                        users(:user_two).id, 
                                        accounts(:company_one_vendor_one).id])
    assert ! ActionMailer::Base.deliveries.empty?
    assert_equal 'Payment Request', ActionMailer::Base.deliveries[0].subject
    assert_response :redirect
    assert_redirected_to payments_path(users(:user_two).company)
  end

  def test_should_create_a_new_payment_record_and_send_an_email_when_not_given_any_reasons_on_POST_to_create
    Payment.delete_all
    company = companies :company_two
    5.times do 
      company.trades.create! :direction => 'BUY',
        :quantity => 100,
        :symbol => 'MSFT',
        :average_price => 100.0,
        :made_on => Date.today,
        :execution_type => 'SOFT'
    end

    PDF::Writer.any_instance.expects(:image)

    post :create, { 
      :company_id => users(:user_two).company.id,
      :payment => { 
        :amount => 0.50, 
        :account_id => accounts(:company_two_vendor_two).id,
        :request => 'Notes' 
      } 
    }, :user_id => users(:user_two).id

    assert Payment.find(:first,
                        :conditions => ['amount = ? 
                                         and user_id = ? 
                                         and account_id = ?',
                                        0.50, 
                                        users(:user_two).id, 
                                        accounts(:company_two_vendor_two).id])
    assert ! ActionMailer::Base.deliveries.empty?
    assert_equal 'Payment Request', 
    ActionMailer::Base.deliveries.first.subject
    assert_response :redirect
    assert_redirected_to payments_path(users(:user_two).company)
  end

  def test_should_create_a_new_payment_and_a_new_reason_for_other_on_POST_to_create
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

    PDF::Writer.any_instance.stubs(:image)

    post :create, { 
      :company_id => users(:user_two).company.id,
      :payment => { 
        :amount => 0.50, 
        :account_id => accounts(:company_one_vendor_one).id 
      },
      :other => '1',
      :other_description => 'here we go' 
    }, :user_id => users(:user_two).id

    assert ! ActionMailer::Base.deliveries.empty?
    assert_response :redirect
    assert_redirected_to payments_path(users(:user_two).company)
    reasons = assigns(:payment).reasons
    assert_equal 1, reasons.size
    assert_equal 'here we go', reasons[0]
  end

  def test_should_not_create_an_invalid_payment_record_on_POST_to_create
    Payment.any_instance.expects(:save).returns false

    post :create, { 
      :company_id => users(:user_two).company.id,
      :user_id => users(:user_two).id,
      :payment => { 
        :amount => nil 
      } 
    }, :user_id => users(:user_two).id

    assert ! assigns(:payment).valid?
    assert ActionMailer::Base.deliveries.empty?
    assert_response :success
    assert_template 'new'
  end

  def test_should_find_all_pending_payments_for_the_current_users_companys_accounts_on_GET_to_index
    assert_recognizes({ :controller => 'payments',
                        :action => 'index',
                        :company_id => '2' },
                      :path => 'companies/2/payments', :method => :get)
    get :index, {
      :company_id => users(:user_three).company.id,
    }, :user_id => users(:user_three).id

    
    assert_equal users(:user_three).company, assigns(:company)
    account_ids = users(:user_three).company.accounts.collect do |each|
      each.id
    end
    assert_equal Payment.find(:all,
                              :conditions => { :account_id => account_ids }),
      assigns(:payments)
    assert_response :success
    assert_template 'index'
  end

  def test_should_delete_the_payment_with_the_given_id_on_DELETE_to_destroy
    assert_recognizes({ :controller => 'payments',
                        :action => 'destroy',
                        :company_id => '1',
                        :id => '1' },
                      :path => 'companies/1/payments/1', :method => :delete)
    payment = payments :user_two_company_two_vendor_two_account

    delete :destroy, {
      :company_id => users(:user_three).company.id,
      :id => payment.id
    }, :user_id => users(:user_three).id

    assert_equal users(:user_three).company, assigns(:company)
    assert ! Payment.exists?(payment.id)
    assert ! ActionMailer::Base.deliveries.empty?
    assert_not_nil flash[:notice]
    assert_response :redirect
    assert_redirected_to payments_path(users(:user_three).company)
  end    

end
