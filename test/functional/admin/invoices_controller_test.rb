require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/invoices_controller'

# Re-raise errors caught by the controller.
class Admin::InvoicesController; def rescue_action(e) raise e end; end

class Admin::InvoicesControllerTest < Test::Unit::TestCase

  fixtures :users, 
    :payments, 
    :invoices,
    :companies,
    :accounts

  def setup
    @controller = Admin::InvoicesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login_as_admin
  end

  def login_as_admin
    get :new, { :payment_id => payments(:user_two_company_one_vendor_one_account).id }, 
    :user_id => users(:user_one).id
  end

  def test_should_create_a_new_invoice_object_on_GET_to_new
    assert_recognizes({ :controller => 'admin/invoices',
                        :action => 'new' },
                      :path => 'admin/invoices/new', :method => :get)

    get :new, :payment_id => payments(:user_two_company_one_vendor_one_account).id

    assert_kind_of Invoice, assigns(:invoice)
    assert_equal payments(:user_two_company_one_vendor_one_account), assigns(:payment)
    assert_response :success
    assert_template 'new'
  end

  def test_should_create_a_new_invoice_record_on_POST_to_create
    assert_recognizes({ :controller => 'admin/invoices',
                        :action => 'create' },
                      :path => 'admin/invoices', :method => :post)

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

    PDF::Writer.
      any_instance.
      expects(:image)

    payment = Payment.create! :user => users(:user_two),
      :account => accounts(:company_one_vendor_one),
      :amount => 2.00

    post :create, 
      :payment_id => payment.id,
      :invoice => { 
        :number => 'I-7',
        :amount => payment.amount_due - 1,
        :start_date => Time.now.beginning_of_month.to_date,
        :end_date => Time.now.end_of_month.to_date,
        :check_number => '50',
        :paid_on => Time.now.to_date 
      }

    assert Invoice.find(:first,
                        :conditions => ['payment_id = ?', payment.id])
    assert_response :redirect
    assert_redirected_to admin_invoice_path(assigns(:invoice))
  end

  def test_should_not_create_an_invalid_invoice_record_on_POST_to_create
    Invoice.any_instance.expects(:save).returns false
    
    post :create, 
    :payment_id => payments(:user_two_company_one_vendor_one_account).id,
    :invoice => {}

    assert_response :success
    assert_template 'new'
  end

  def test_should_paginate_all_invoices_on_GET_to_index
    assert_recognizes({ :controller => 'admin/invoices',
                        :action => 'index' },
                      :path => 'admin/invoices', :method => :get)

    get :index

    assert_equal Invoice.find(:all,
                              :order => 'start_date'),
    assigns(:invoices)
    assert_response :success
    assert_template 'index'
  end

  def test_should_find_the_invoice_record_with_the_given_id_on_GET_to_show
    assert_recognizes({ :controller => 'admin/invoices',
                        :action => 'show',
                        :id => '1' },
                      :path => 'admin/invoices/1', :method => :get)

    get :show, :id => invoices(:company_one_vendor_one_this_month).id

    assert_equal invoices(:company_one_vendor_one_this_month), assigns(:invoice)
    assert_response :success
    assert_template 'show'
  end

  def test_should_delete_the_invoice_record_with_the_given_id_on_DELETE_to_destroy
    assert_recognizes({ :controller => 'admin/invoices',
                        :action => 'destroy',
                        :id => '1' },
                      :path => 'admin/invoices/1', :method => :delete)

    delete :destroy, :id => invoices(:company_one_vendor_one_this_month).id

    assert ! Invoice.exists?(invoices(:company_one_vendor_one_this_month).id)
    assert_response :redirect
    assert_redirected_to admin_invoices_path
  end

end


