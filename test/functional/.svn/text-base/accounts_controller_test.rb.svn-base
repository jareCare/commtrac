require File.dirname(__FILE__) + '/../test_helper'
require 'accounts_controller'

# Re-raise errors caught by the controller.
class AccountsController; def rescue_action(e) raise e end; end

class AccountsControllerTest < Test::Unit::TestCase

  fixtures :users, 
    :accounts, 
    :organizations,
    :companies

  def setup
    @controller = AccountsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_find_the_account_record_with_the_given_id_on_GET_to_show
    assert_recognizes({ :controller => 'accounts',
                        :action => 'show',
                        :company_id => '2',
                        :id => '3' },
                      :path => 'companies/2/accounts/3', :method => :get)

    get :show, { 
      :company_id => users(:user_one).company.id,
      :id => accounts(:company_one_vendor_one).id 
    }, :user_id => users(:user_one).id

    assert_equal users(:user_one).company, assigns(:company)
    assert_equal accounts(:company_one_vendor_one), assigns(:account)
    assert_response :success
    assert_template 'show'
  end

end
