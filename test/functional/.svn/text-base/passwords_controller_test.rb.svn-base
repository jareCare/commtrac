require File.dirname(__FILE__) + '/../test_helper'
require 'passwords_controller'

# Re-raise errors caught by the controller.
class PasswordsController; def rescue_action(e) raise e end; end

class PasswordsControllerTest < Test::Unit::TestCase

  fixtures :users,
    :companies

  def setup
    @controller = PasswordsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_find_the_user_record_with_the_given_id_and_hashed_password_on_GET_to_new
    assert_recognizes({ :controller => 'passwords',
                        :action => 'new' },
                      :path => 'passwords/new', :method => :get)

    get :new, 
      :_u => users(:user_one).id, 
      :_p => users(:user_one).password

    assert_equal users(:user_one), assigns(:user)
    assert assigns(:user).password.blank?
    assert_response :success
    assert_template 'new'
  end

  def test_should_create_a_new_password_for_the_user_record_with_the_given_id_and_hashed_password_on_POST_to_create
    assert_recognizes({ :controller => 'passwords',
                        :action => 'create' },
                      :path => 'passwords', :method => :post)

    post :create, 
      :_u => users(:user_two).id,
      :_p => users(:user_two).password,
      :user => { 
        :password => 'new password',
        :password_confirmation => 'new password' 
      }

    users(:user_two).reload
    assert_equal 'new password'.to_sha1, users(:user_two).password
    assert_equal users(:user_two).id, session[:user_id]
    assert_response :redirect
    assert_redirected_to user_path(users(:user_two).company, users(:user_two))
  end

  def test_should_not_create_a_new_password_for_the_user_record_with_the_given_id_if_the_passwords_dont_match_on_POST_to_create
    post :create, 
      :_u => users(:user_two).id,
      :_p => users(:user_two).password,
      :user => { 
        :password => 'one',
        :password_confirmation => 'two' 
      }

    users(:user_one).reload
    assert_equal 'user one'.to_sha1, users(:user_one).password
    assert_equal 'one', assigns(:user).password
    assert_equal 'two', assigns(:user).password_confirmation
    assert_response :success
    assert_template 'new'
  end

  def test_should_not_create_a_new_password_for_the_user_record_with_the_given_id_if_no_password_is_given_on_POST_to_create
    post :create, 
      :_u => users(:user_two).id,
      :_p => users(:user_two).password,
      :user => { 
        :password => '',
        :password_confirmation => '' 
      }

    users(:user_one).reload
    assert_equal 'user one'.to_sha1, users(:user_one).password
    assert assigns(:user).password.blank?
    assert assigns(:user).password_confirmation.blank?
    assert_response :success
    assert_template 'new'
  end

end
