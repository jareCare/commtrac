require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/companies_controller'

# Re-raise errors caught by the controller.
class Admin::CompaniesController; def rescue_action(e) raise e end; end

class Admin::CompaniesControllerTest < Test::Unit::TestCase

  fixtures :users, :companies

  def setup
    @controller = Admin::CompaniesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login_as_admin
  end

  def login_as_admin
    get :new, {}, :user_id => users(:user_one).id
  end

  def test_should_create_a_new_company_object_on_GET_to_new
    assert_recognizes({ :controller => 'admin/companies',
                        :action => 'new' },
                      :path => 'admin/companies/new', :method => :get)
    get :new

    assert_kind_of Company, assigns(:company)
    assert_response :success
    assert_template 'new'
  end

  def test_should_create_a_new_company_record_on_POST_to_create
    assert_recognizes({ :controller => 'admin/companies',
                        :action => 'create' },
                      :path => 'admin/companies', :method => :post)

    post :create, :company => { 
      :name => 'Company Two',
      :best_commission_rate => '5.50',
      :soft_commission_rate => '5.50',
      :credit_rate => '10.00' }

    assert Company.find(:first,
                        :conditions => "name = 'Company Two'")
    assert_response :redirect
    assert_redirected_to admin_company_path(assigns(:company))
  end

  def test_should_not_create_an_invalid_company_record_on_POST_to_create
    Company.any_instance.expects(:save).returns false

    post :create, :company => { :name => 'Company Two' }

    assert_response :success
    assert_template 'new'
  end

  def test_should_paginate_all_companies_on_GET_to_index
    assert_recognizes({ :controller => 'admin/companies',
                        :action => 'index' },
                      :path => 'admin/companies', :method => :get)

    get :index

    assert_equal Company.find(:all), assigns(:companies)
    assert_response :success
    assert_template 'index'
  end

  def test_should_find_the_company_record_with_the_given_id_on_GET_to_show
    assert_recognizes({ :controller => 'admin/companies',
                        :action => 'show',
                        :id => '1' },
                      :path => 'admin/companies/1', :method => :get)

    get :show, :id => companies(:company_one).id

    assert_equal companies(:company_one), assigns(:company)
    assert_response :success
    assert_template 'show'
  end

  def test_should_find_the_company_record_with_the_given_id_on_GET_to_edit
    assert_recognizes({ :controller => 'admin/companies',
                        :action => 'edit',
                        :id => '1' },
                      :path => 'admin/companies/1;edit', :method => :get)

    get :edit, :id => companies(:company_one).id

    assert_equal companies(:company_one), assigns(:company)
    assert_response :success
    assert_template 'edit'
  end

  def test_should_update_the_company_record_with_the_given_id_on_PUT_to_update
    assert_recognizes({ :controller => 'admin/companies',
                        :action => 'update',
                        :id => '1' },
                      :path => 'admin/companies/1', :method => :put)

    put :update, :id => companies(:company_one).id,
    :company => { :name => 'name' }

    companies(:company_one).reload
    assert_equal 'name', companies(:company_one).name
    assert_response :redirect
    assert_redirected_to admin_company_path(companies(:company_one))
  end

  def test_should_not_update_the_company_record_with_the_given_id_to_an_invalid_state_on_PUT_to_update
    Company.any_instance.expects(:update_attributes).returns false

    put :update, :id => companies(:company_one).id,
    :company => { }

    assert_response :success
    assert_template 'edit'
  end

  def test_should_delete_the_company_record_with_the_given_id_on_DELETE_to_destroy
    assert_recognizes({ :controller => 'admin/companies',
                        :action => 'destroy',
                        :id => '1' },
                      :path => 'admin/companies/1', :method => :delete)

    delete :destroy, :id => companies(:company_one).id

    assert ! Company.exists?(companies(:company_one).id)
    assert_response :redirect
    assert_redirected_to admin_companies_path
  end

  def test_should_store_the_given_end_date_on_GET_to_show
    date = Time.now.midnight

    get :show, {
      :id => companies(:company_one).id,
      :end_date => {
        :year => date.year.to_s,
        :month => date.month.to_s,
        :day => date.day.to_s
      }
    }, :user_id => users(:user_two).id

    assert_equal date, assigns(:end_date)
    assert_response :success
    assert_template 'show'
  end

end
