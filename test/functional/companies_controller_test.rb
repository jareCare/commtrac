require File.dirname(__FILE__) + '/../test_helper'
require 'companies_controller'

# Re-raise errors caught by the controller.
class CompaniesController; def rescue_action(e) raise e end; end

class CompaniesControllerTest < Test::Unit::TestCase

  fixtures :users, :companies

  def setup
    @controller = CompaniesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_find_the_company_record_with_the_given_id_on_GET_to_show
    assert_recognizes({ :controller => 'companies',
                        :action => 'show',
                        :id => '3' },
                      :path => 'companies/3', :method => :get)

    get :show, { :id => companies(:company_one).id },
    :user_id => users(:user_one).id

    assert_equal companies(:company_one), assigns(:company)
    assert_response :success
    assert_template 'show'
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

  def test_should_require_the_user_to_be_logged_in_on_GET_to_index
    assert_recognizes({ :controller => 'companies',
                        :action => 'index' },
                      :path => '/', 
                      :method => :get)
    get :index

    assert_response :redirect
    assert_redirected_to new_session_path
  end

  def test_should_redirect_a_non_admin_user_to_their_non_admin_page_on_GET_to_index
    get :index, {}, :user_id => users(:user_two).id

    assert_response :redirect
    assert_redirected_to user_path(users(:user_two).company,
                                   users(:user_two))
  end

  def test_should_redirec_an_admin_user_to_the_admin_companies_listing_on_GET_to_index
    get :index, {}, :user_id => users(:user_one).id

    assert_response :redirect
    assert_redirected_to admin_companies_path
  end

end
