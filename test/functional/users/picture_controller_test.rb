require File.dirname(__FILE__) + '/../../test_helper'
require 'users/picture_controller'

# Re-raise errors caught by the controller.
class Users::PictureController; def rescue_action(e) raise e end; end

class Users::PictureControllerTest < Test::Unit::TestCase

  fixtures :users, 
    :companies,
    :pictures

  def setup
    @controller = Users::PictureController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_create_a_new_picture_object_on_GET_to_new
    assert_recognizes({ :controller => 'users/picture',
                        :action => 'new',
                        :company_id => '1',
                        :user_id => '2' },
                      :path => 'companies/1/users/2/picture/new', :method => :get)

    get :new, { 
      :company_id => users(:user_one).company.id,
      :user_id => users(:user_one).id 
    }, :user_id => users(:user_one).id

    assert_equal users(:user_one).company, assigns(:company)
    assert_equal users(:user_one), assigns(:user)
    assert_kind_of Picture, assigns(:picture)
    assert_response :success
    assert_template 'new'
  end

  def test_should_create_a_new_picture_record_on_POST_to_create
    assert_recognizes({ :controller => 'users/picture',
                        :action => 'create',
                        :company_id => '2',
                        :user_id => '1' },
                      :path => 'companies/2/users/1/picture', :method => :post)

    old_count = Picture.count

    post :create, {
      :company_id => users(:user_one).company.id,
      :user_id => users(:user_one).id,
      :picture => {
        :uploaded_data => fixture_file_upload(File.join('pictures', 'image.jpg'), 'image/jpg')
      }
    }, :user_id => users(:user_one).id

    assert_equal users(:user_one).company, assigns(:company)
    assert_equal users(:user_one), assigns(:user)
    assert_equal old_count + 1, Picture.count
    assert_equal users(:user_one), assigns(:picture).subject
    assert_response :redirect
    assert_redirected_to user_path(users(:user_one).company, users(:user_one))
  end

  def test_should_not_create_pictures_for_empty_files_on_POST_to_create
    old_count = Picture.count

    post :create, {
      :company_id => users(:user_one).company.id,
      :user_id => users(:user_one).id,
      :picture => {
        :uploaded_data => ''
      }
    }, :user_id => users(:user_one).id

    assert_equal old_count, Picture.count
    assert_response :redirect
    assert_redirected_to user_path(users(:user_one).company,
                                   users(:user_one))
  end

  def test_should_delete_the_picture_record_for_the_user_with_the_given_id_on_DELETE_to_destroy
    assert_recognizes({ :controller => 'users/picture',
                        :action => 'destroy',
                        :company_id => '2',
                        :user_id => '1' },
                      :path => 'companies/2/users/1/picture', :method => :delete)

    delete :destroy, { 
      :company_id => pictures(:user_two).subject.company.id,
      :user_id => pictures(:user_two).subject.id,
      :id => pictures(:user_two).id 
    }, :user_id => users(:user_two).id

    assert_equal users(:user_two).company, assigns(:company)
    assert_equal users(:user_two), assigns(:user)
    assert ! Picture.exists?(pictures(:user_two).id)
    assert_response :redirect
    assert_redirected_to user_path(users(:user_two).company, users(:user_two))
  end

end
