require File.dirname(__FILE__) + '/../test_helper'
require 'session_controller'

# Re-raise errors caught by the controller.
class SessionController; def rescue_action(e) raise e end; end

class SessionControllerTest < Test::Unit::TestCase

  fixtures :users

  def setup
    @controller = SessionController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_render_the_new_view_on_GET_to_new
    assert_recognizes({ :controller => 'session',
                        :action => 'new' },
                      :path => 'session/new', :method => :get)
    get :new

    assert_response :success
    assert_template 'new'
  end

  def test_should_create_a_new_session_for_a_valid_non_admin_user_on_POST_to_create
    assert_recognizes({ :controller => 'session',
                        :action => 'create' },
                      :path => 'session', :method => :post)

    post :create, :email => users(:user_two).email,
    :password => 'user two'

    assert_equal users(:user_two).id, session[:user_id]
    assert cookies['token'].nil?
    assert_response :redirect
    assert_redirected_to user_path(users(:user_two).company, users(:user_two))
  end

  def test_should_create_a_new_session_for_a_valid_admin_user_on_POST_to_create
    assert_recognizes({ :controller => 'session',
                        :action => 'create' },
                      :path => 'session', :method => :post)

    post :create, :email => users(:user_one).email,
    :password => 'user one'

    assert_equal users(:user_one).id, session[:user_id]
    assert cookies['token'].nil?
    assert_response :redirect
    assert_redirected_to admin_companies_path
  end

  def test_should_save_a_cookie_if_the_user_asks_to_be_remembered_on_a_successful_login_on_POST_to_create
    post :create, :email => users(:user_two).email,
    :password => 'user two', 
    :remember_me => '1'

    assert_equal users(:user_two).reload.token, cookies['token'][0]
    assert_response :redirect
    assert_redirected_to user_path(users(:user_two).company, users(:user_two))
  end

  def test_should_not_create_a_new_session_for_a_invalid_user_on_POST_to_create
    post :create, :email => 'email',
    :password => 'password'

    assert_response :success
    assert_template 'new'
    assert_select 'p#flash', /invalid/i
  end

  def test_should_clear_the_session_on_DELETE_to_destroy
    @request.cookies['token'] = CGI::Cookie.new 'token', users(:user_one).token

    delete :destroy, {}, :user_id => users(:user_one).id

    assert_nil session[:user_id]
    assert cookies['token'].empty?
    assert_response :redirect
    assert_redirected_to new_session_path
  end

end
