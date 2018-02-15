require File.dirname(__FILE__) + '/../test_helper'
require 'reminders_controller'

# Re-raise errors caught by the controller.
class RemindersController; def rescue_action(e) raise e end; end

class RemindersControllerTest < Test::Unit::TestCase

  fixtures :users

  def setup
    @controller = RemindersController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    RemindersMailer.deliveries.clear
  end

  def test_should_render_the_new_page_on_GET_to_new
    assert_recognizes({ :controller => 'reminders',
                        :action => 'new' },
                      :path => 'reminders/new', :method => :get)
    get :new

    assert_response :success
    assert_template 'new'
  end

  def test_should_send_an_email_to_the_user_with_the_given_email_on_POST_to_create
    assert_recognizes({ :controller => 'reminders',
                        :action => 'create' },
                      :path => 'reminders', :method => :post)

    post :create, :email => users(:user_one).email

    assert ! RemindersMailer.deliveries.empty?
    assert_not_nil flash[:notice]
    assert_response :redirect
    assert_redirected_to new_session_path
  end

  def test_should_not_send_an_email_to_an_unregistered_email_on_POST_to_creat
    post :create, :email => 'email'

    assert_response :success
    assert_template 'new'
    assert_select 'p#flash', /unknown/i
  end

end
