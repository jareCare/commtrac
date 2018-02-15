require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/payments_controller'

# Re-raise errors caught by the controller.
class Admin::PaymentsController; def rescue_action(e) raise e end; end

class Admin::PaymentsControllerTest < Test::Unit::TestCase

  fixtures :payments, 
    :users, 
    :accounts,
    :companies, 
    :organizations

  def setup
    @controller = Admin::PaymentsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    ActionMailer::Base.deliveries.clear
    login_as_admin
  end

  def login_as_admin
    get :index, {}, :user_id => User.admins.first.id
  end

  def test_should_find_all_payments_on_GET_to_index
    assert_recognizes({ :controller => 'admin/payments',
                        :action => 'index' },
                      :path => 'admin/payments', :method => :get)

    get :index

    assert_equal Payment.find(:all), assigns(:payments)
    assert_response :success
    assert_template 'index'
  end

  def test_should_find_the_payment_record_with_the_given_id_on_GET_to_edit
    assert_recognizes({ :controller => 'admin/payments',
                        :action => 'edit',
                        :id => '1' },
                      :path => 'admin/payments/1;edit', :method => :get)

    get :edit, :id => payments(:user_two_company_one_vendor_one_account).id

    assert_equal payments(:user_two_company_one_vendor_one_account), assigns(:payment)
    assert_response :success
    assert_template 'edit'
  end

  def test_should_mark_the_payment_as_no_longer_pending_but_accepted_and_send_an_email_to_the_payment_requester_when_accepting_a_payment_on_PUT_to_update
    assert_recognizes({ :controller => 'admin/payments',
                        :action => 'update',
                        :id => '1' },
                      :path => 'admin/payments/1', :method => :put)

    put :update, 
    :id => payments(:user_two_company_one_vendor_one_account).id,
    :payment => {},
    :decision => 'yes'

    payments(:user_two_company_one_vendor_one_account).reload
    assert ! payments(:user_two_company_one_vendor_one_account).pending?
    assert payments(:user_two_company_one_vendor_one_account).accepted?
    assert ! ActionMailer::Base.deliveries.empty?
    assert_equal 'Payment Accepted', ActionMailer::Base.deliveries.first.subject
    assert_response :redirect
    assert_redirected_to admin_new_invoice_path(:payment_id => payments(:user_two_company_one_vendor_one_account))
  end

  def test_should_mark_the_payment_as_rejected_and_send_an_email_to_the_payment_requester_when_rejecting_a_payment_on_PUT_to_update
    put :update, :id => payments(:user_two_company_one_vendor_one_account).id,
    :payment => {},
    :decision => 'no'

    payments(:user_two_company_one_vendor_one_account).reload
    assert payments(:user_two_company_one_vendor_one_account).rejected?
    assert ! payments(:user_two_company_one_vendor_one_account).pending?
    assert ! payments(:user_two_company_one_vendor_one_account).accepted?
    assert ! ActionMailer::Base.deliveries.empty?
    assert_equal 'Payment Rejected', ActionMailer::Base.deliveries.first.subject
    assert_response :redirect
    assert_redirected_to admin_payments_path
  end

  def test_should_find_the_payment_record_with_the_given_id_on_GET_to_show
    assert_recognizes({ :controller => 'admin/payments',
                        :action => 'show',
                        :id => '1' },
                      :path => 'admin/payments/1', :method => :get)

    get :show, :id => payments(:user_two_company_one_vendor_one_account).id

    assert_equal payments(:user_two_company_one_vendor_one_account), assigns(:payment)
    assert_response :success
    assert_template 'show'
  end

  def test_should_not_be_able_to_find_the_payment_record_with_the_given_id_if_its_already_been_accepted_on_GET_to_edit
    assert payments(:user_two_company_one_vendor_one_account).update_attribute(:status, 'Accepted')

    get :edit, :id => payments(:user_two_company_one_vendor_one_account).id

    assert_response :redirect
    assert_redirected_to admin_payments_path
  end

end
