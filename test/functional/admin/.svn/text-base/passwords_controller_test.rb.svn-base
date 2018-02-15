require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/passwords_controller'

# Re-raise errors caught by the controller.
class Admin::PasswordsController; def rescue_action(e) raise e end; end

class Admin::PasswordsControllerTest < Test::Unit::TestCase

  fixtures :users

  def setup
    @controller = Admin::PasswordsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login_as_admin
  end

  def login_as_admin
    get :new, { :user_id => users(:user_two).id }, 
    :user_id => users(:user_one).id
  end

  def test_should_find_the_user_record_with_the_given_id_on_GET_to_new
    assert_recognizes({ :controller => 'admin/passwords',
                        :action => 'new' },
                      :path => 'admin/passwords/new', :method => :get)

    get :new, :user_id => users(:user_two).id

    assert_equal users(:user_two), assigns(:user)
    assert assigns(:user).password.blank?
    assert_response :success
    assert_template 'new'
  end

  def test_should_create_a_new_password_for_the_user_record_with_the_given_id_on_POST_to_create
    assert_recognizes({ :controller => 'admin/passwords',
                        :action => 'create' },
                      :path => 'admin/passwords', :method => :post)

    post :create, :user_id => users(:user_two).id,
    :user => { :password => 'new password',
      :password_confirmation => 'new password' }

    users(:user_two).reload
    assert_equal Digest::SHA1.hexdigest('new password'), users(:user_two).password
    assert_equal users(:user_one).id, session[:user_id]
    assert_response :redirect
    assert_redirected_to admin_user_path(users(:user_two))
  end

  def test_should_not_create_a_new_password_for_the_user_record_with_the_given_id_if_the_passwords_dont_match_on_POST_to_create
    post :create, :user_id => users(:user_two).id,
    :user => { :password => 'one',
      :password_confirmation => 'two' }

    users(:user_two).reload
    assert_equal Digest::SHA1.hexdigest('user two'), users(:user_two).password
    assert_equal 'one', assigns(:user).password
    assert_equal 'two', assigns(:user).password_confirmation
    assert_response :success
    assert_template 'new'
  end

  def test_should_not_create_a_new_password_for_the_user_record_with_the_given_id_if_no_password_is_given_on_POST_to_create
    post :create, :user_id => users(:user_two).id,
    :user => { :password => '',
      :password_confirmation => '' }

    users(:user_two).reload
    assert_equal Digest::SHA1.hexdigest('user two'), users(:user_two).password
    assert assigns(:user).password.blank?
    assert assigns(:user).password_confirmation.blank?
    assert_response :success
    assert_template 'new'
  end

end
