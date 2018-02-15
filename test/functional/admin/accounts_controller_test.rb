require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/accounts_controller'

# Re-raise errors caught by the controller.
class Admin::AccountsController; def rescue_action(e) raise e end; end

class Admin::AccountsControllerTest < Test::Unit::TestCase

  fixtures :companies, 
    :organizations, 
    :users,
    :accounts

  def setup
    @controller = Admin::AccountsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login_as_admin
  end

  def login_as_admin
    get :new, { :company_id => companies(:company_one).id }, 
    :user_id => users(:user_one).id
  end

  def test_should_find_the_company_record_with_the_given_id_on_GET_to_new
    assert_recognizes({ :controller => 'admin/accounts',
                        :action => 'new' },
                      :path => 'admin/accounts/new', :method => :get)

    get :new, :company_id => companies(:company_one).id

    assert_kind_of Account, assigns(:account)
    assert_equal companies(:company_one), assigns(:company)
    assert_response :success
    assert_template 'new'
  end

  def test_should_create_a_new_account_record_on_POST_to_create
    assert_recognizes({ :controller => 'admin/accounts',
                        :action => 'create' },
                      :path => 'admin/accounts', :method => :post)

    post :create, 
      :company_id => companies(:company_one).id,
      :account => { 
        :number => '001',
        :organization_id => organizations(:broker_one).id 
      }

    assert Account.find(:first, 
                        :conditions => 'number = 001')
    assert_response :redirect
    assert_redirected_to admin_account_path(assigns(:account))
  end

  def test_should_not_create_an_invalid_account_record_on_POST_to_create
    Account.any_instance.expects(:save).returns false

    post :create, 
      :company_id => companies(:company_one).id,
      :account => { 
        :number => '001' 
      }

    assert_response :success
    assert_template 'new'
  end

  def test_should_paginate_all_accounts_on_GET_to_index
    assert_recognizes({ :controller => 'admin/accounts',
                        :action => 'index' },
                      :path => 'admin/accounts', :method => :get)
    get :index

    assert_equal Account.find(:all), assigns(:accounts)
    assert_response :success
    assert_template 'index'
  end

  def test_should_find_the_account_record_with_the_given_id_on_GET_to_show
    assert_recognizes({ :controller => 'admin/accounts',
                        :action => 'show',
                        :id => '2' },
                      :path => 'admin/accounts/2', :method => :get)

    get :show, :id => accounts(:company_one_vendor_one).id

    assert_equal accounts(:company_one_vendor_one), assigns(:account)
    assert_response :success
    assert_template 'show'
  end

  def test_should_find_the_account_record_with_the_given_id_on_GET_to_edit
    assert_recognizes({ :controller => 'admin/accounts',
                        :action => 'edit',
                        :id => '2' },
                      :path => 'admin/accounts/2;edit', :method => :get)

    get :edit, :id => accounts(:company_one_vendor_one).id

    assert_equal accounts(:company_one_vendor_one), assigns(:account)
    assert_response :success
    assert_template 'edit'
  end

  def test_should_update_the_account_record_with_the_given_id_on_PUT_to_update
    assert_recognizes({ :controller => 'admin/accounts',
                        :action => 'update',
                        :id => '1' },
                      :path => 'admin/accounts/1', :method => :put)

    put :update, 
      :id => accounts(:company_one_vendor_one).id,
      :account => { 
        :number => 'A-2' 
      }

    accounts(:company_one_vendor_one).reload
    assert_equal 'A-2', accounts(:company_one_vendor_one).number
    assert_response :redirect
    assert_redirected_to admin_account_path(accounts(:company_one_vendor_one))
  end

  def test_should_not_update_the_account_record_with_the_given_id_to_an_invalid_state_on_PUT_to_update
    Account.any_instance.expects(:update_attributes).returns false

    put :update, 
      :id => accounts(:company_one_vendor_one).id,
      :account => {}

    assert_response :success
    assert_template 'edit'
  end

  def test_should_delete_the_account_record_with_the_given_id_on_DELETE_to_destroy
    assert_recognizes({ :controller => 'admin/accounts',
                        :action => 'destroy',
                        :id => '4' },
                      :path => 'admin/accounts/4', :method => :delete)

    delete :destroy, :id => accounts(:company_one_vendor_one).id

    assert ! Account.exists?(accounts(:company_one_vendor_one).id)
    assert_response :redirect
    assert_redirected_to admin_accounts_path
  end

end
