require File.dirname(__FILE__) + '/../test_helper'
require 'organizations_controller'

# Re-raise errors caught by the controller.
class OrganizationsController; def rescue_action(e) raise e end; end

class OrganizationsControllerTest < Test::Unit::TestCase

  fixtures :users, :organizations

  def setup
    @controller = OrganizationsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_find_the_vendor_record_with_the_given_id_on_GET_to_show
    get :show, { :id => organizations(:vendor_one).id },
    :user_id => users(:user_one).id

    assert_equal organizations(:vendor_one), assigns(:organization)
    assert_response :success
    assert_template 'show'
  end

end
