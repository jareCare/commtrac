require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/users_controller'

# Re-raise errors caught by the controller.
class Admin::UsersController; def rescue_action(e) raise e end; end

class Admin::UsersControllerTest < Test::Unit::TestCase

  fixtures :users, 
    :companies

  def setup
    @controller = Admin::UsersController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login_as_admin
  end

  def login_as_admin
    get :new, { 
      :company_id => companies(:company_one).id 
    }, :user_id => users(:user_one).id
  end

  def test_should_create_a_new_user_object_on_GET_to_new
    assert_recognizes({ :controller => 'admin/users',
                        :action => 'new' },
                      :path => 'admin/users/new', :method => :get)

    get :new

    assert_kind_of User, assigns(:user)
    assert_response :success
    assert_template 'new'
  end

  def test_should_create_a_new_user_record_on_POST_to_create
    assert_recognizes({ :controller => 'admin/users',
                        :action => 'create' },
                      :path => 'admin/users', :method => :post)

    post :create, 
    :user => { 
      :email => 'email', 
      :password => 'password',
      :password_confirmation => 'password',
      :first_name => 'first',
      :last_name => 'last',
      :company_id => companies(:company_one).id,
    }

    assert User.find(:first,
                     :conditions => "email = 'email'")
    assert_equal companies(:company_one), assigns(:user).company
    assert_response :redirect
    assert_redirected_to admin_user_path(assigns(:user))
  end

  def test_should_not_create_an_invalid_user_record_on_POST_to_create
    User.any_instance.expects(:save).returns false

    post :create,
    :user => {}

    assert_response :success
    assert_template 'new'
  end

  def test_should_find_all_users_on_GET_to_index
    assert_recognizes({ :controller => 'admin/users',
                        :action => 'index' },
                      :path => 'admin/users', :method => :get)

    get :index

    assert_equal User.find(:all), assigns(:users)
    assert_response :success
    assert_template 'index'
  end

  def test_should_find_the_user_record_with_the_given_id_on_GET_to_show
    assert_recognizes({ :controller => 'admin/users',
                        :action => 'show',
                        :id => '2' },
                      :path => 'admin/users/2', :method => :get)

    get :show, :id => users(:user_two).id

    assert_equal users(:user_two), assigns(:user)
    assert_response :success
    assert_template 'show'
  end

  def test_should_find_the_user_record_with_the_given_id_on_GET_to_edit
    assert_recognizes({ :controller => 'admin/users',
                        :action => 'edit',
                        :id => '2' },
                      :path => 'admin/users/2;edit', :method => :get)

    get :edit, :id => users(:user_two).id

    assert_equal users(:user_two), assigns(:user)
    assert_response :success
    assert_template 'edit'
  end
  
  def test_should_update_the_user_record_with_the_given_id_on_PUT_to_update
    assert_recognizes({ :controller => 'admin/users',
                        :action => 'update',
                        :id => '2' },
                      :path => 'admin/users/2', :method => :put)

    put :update, :id => users(:user_two).id,
    :user => { :email => 'email' }

    users(:user_two).reload
    assert_equal 'email', users(:user_two).email
    assert_response :redirect
    assert_redirected_to admin_user_path(users(:user_two))
  end

  def test_should_not_update_the_user_record_with_the_given_id_to_an_invalid_state_on_PUT_to_update
    User.any_instance.expects(:update_attributes).returns false

    put :update, :id => users(:user_two).id,
    :user => {}

    assert_response :success
    assert_template 'edit'
  end

  def test_should_delete_the_user_record_with_the_given_id_on_DELETE_to_destroy
    assert_recognizes({ :controller => 'admin/users',
                        :action => 'destroy',
                        :id => '2' },
                      :path => 'admin/users/2', :method => :delete)

    delete :destroy, :id => users(:user_two).id

    assert ! User.exists?(users(:user_two).id)
    assert_response :redirect
    assert_redirected_to admin_users_path
  end

  def test_should_store_the_given_end_date_on_GET_to_show
    date = Time.now.midnight

    get :show, {
      :id => users(:user_one).id,
      :end_date => {
        :year => date.year.to_s,
        :month => date.month.to_s,
        :day => date.day.to_s
      }
    }, :user_id => users(:user_one).id

    assert_equal date, assigns(:end_date)
    assert_response :success
    assert_template 'show'
  end

end
