require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/organizations_controller'

# Re-raise errors caught by the controller.
class Admin::OrganizationsController; def rescue_action(e) raise e end; end

class Admin::OrganizationsControllerTest < Test::Unit::TestCase

  fixtures :users, 
    :organizations

  def setup
    @controller = Admin::OrganizationsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login_as_admin
  end

  def login_as_admin
    get :new, {}, :user_id => users(:user_one).id
  end

  def test_should_create_a_new_vendor_object_on_GET_to_new
    assert_recognizes({ :controller => 'admin/organizations',
                        :action => 'new' },
                      :path => 'admin/organizations/new', :method => :get)

    get :new

    assert_kind_of Organization, assigns(:organization)
    assert_response :success
    assert_template 'new'
  end

  def test_should_create_a_new_vendor_record_on_POST_to_create
    assert_recognizes({ :controller => 'admin/organizations',
                        :action => 'create' },
                      :path => 'admin/organizations', :method => :post)

    post :create, 
      :organization => { 
        :name => 'name',
        :organization_type => 'Broker'
      }

    assert Organization.find(:first,
                             :conditions => "name = 'name'")
    assert_response :redirect
    assert_redirected_to admin_organization_path(assigns(:organization))
  end

  def test_should_not_create_an_invalid_vendor_record_on_POST_to_create
    Organization.any_instance.expects(:save).returns false
    
    post :create, :vendor => {}

    assert_response :success
    assert_template 'new'
  end

  def test_should_paginate_all_organizations_on_GET_to_index
    assert_recognizes({ :controller => 'admin/organizations',
                        :action => 'index' },
                      :path => 'admin/organizations', :method => :get)

    get :index

    assert_equal Organization.find(:all),
    assigns(:organizations)
    assert_response :success
    assert_template 'index'
  end

  def test_should_find_the_vendor_record_with_the_given_id_on_GET_to_show
    assert_recognizes({ :controller => 'admin/organizations',
                        :action => 'show',
                        :id => '2' },
                      :path => 'admin/organizations/2', :method => :get)

    get :show, :id => organizations(:vendor_one).id

    assert_equal organizations(:vendor_one), assigns(:organization)
    assert_response :success
    assert_template 'show'
  end

  def test_should_find_the_vendor_record_with_the_given_id_on_GET_to_edit
    assert_recognizes({ :controller => 'admin/organizations',
                        :action => 'edit',
                        :id => '2' },
                      :path => 'admin/organizations/2;edit', :method => :get)

    get :edit, :id => organizations(:vendor_one).id

    assert_equal organizations(:vendor_one), assigns(:organization)
    assert_response :success
    assert_template 'edit'
  end

  def test_should_update_the_vendor_record_with_the_given_id_on_PUT_to_update
    assert_recognizes({ :controller => 'admin/organizations',
                        :action => 'update',
                        :id => '2' },
                      :path => 'admin/organizations/2', :method => :put)

    put :update, :id => organizations(:vendor_one).id,
    :organization => { :name => 'name' }

    organizations(:vendor_one).reload
    assert_equal 'name', organizations(:vendor_one).name
    assert_response :redirect
    assert_redirected_to admin_organization_path(organizations(:vendor_one))
  end

  def test_should_not_update_the_vendor_record_with_the_given_id_to_an_invalid_state_on_PUT_to_update
    Organization.any_instance.expects(:update_attributes).returns false

    put :update, :id => organizations(:vendor_one).id,
    :vendor => {}

    assert_response :success
    assert_template 'edit'
  end

  def test_should_delete_the_vendor_record_with_the_given_id_on_DELETE_to_destroy
    assert_recognizes({ :controller => 'admin/organizations',
                        :action => 'destroy',
                        :id => '2' },
                      :path => 'admin/organizations/2', :method => :delete)

    delete :destroy, :id => organizations(:vendor_one).id

    assert ! Organization.exists?(organizations(:vendor_one).id)
    assert_response :redirect
    assert_redirected_to admin_organizations_path
  end

end
