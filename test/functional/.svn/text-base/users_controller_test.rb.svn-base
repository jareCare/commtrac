require File.dirname(__FILE__) + '/../test_helper'
require 'users_controller'

# Re-raise errors caught by the controller.
class UsersController; def rescue_action(e) raise e end; end

class UsersControllerTest < Test::Unit::TestCase

  fixtures :users, :companies

  def setup
    @controller = UsersController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_find_the_user_record_with_the_given_id_on_GET_to_show
    assert_recognizes({ :controller => 'users',
                        :action => 'show',
                        :company_id => '2',
                        :id => '1' },
                      :path => 'companies/2/users/1', :method => :get)

    get :show, { 
      :company_id => users(:user_two).company.id,
      :id => users(:user_two).id
    }, :user_id => users(:user_two).id

    assert_equal users(:user_two).company, assigns(:company)
    assert_equal users(:user_two), assigns(:user)
    assert_response :success
    assert_template 'show'
  end

  def test_should_store_the_given_end_date_on_GET_to_show
    date = Time.now.midnight

    get :show, {
      :company_id => users(:user_one).company.id,
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
