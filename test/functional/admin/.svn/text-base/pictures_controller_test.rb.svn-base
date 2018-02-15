require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/pictures_controller'

# Re-raise errors caught by the controller.
class Admin::PicturesController; def rescue_action(e) raise e end; end

class Admin::PicturesControllerTest < Test::Unit::TestCase

  fixtures :users, :invoices, :pictures

  def setup
    @controller = Admin::PicturesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login_as_admin
  end

  def login_as_admin
    get :new, { :invoice_id => invoices(:company_one_vendor_one_this_month).id }, 
    :user_id => users(:user_one).id
  end

  def test_should_create_a_new_picture_object_on_GET_to_new
    assert_recognizes({ :controller => 'admin/pictures',
                        :action => 'new' },
                      :path => 'admin/pictures/new', :method => :get)

    get :new, { 
      :invoice_id => invoices(:company_one_vendor_one_this_month).id 
    }, :user_id => users(:user_one).id

    assert_kind_of Picture, assigns(:picture)
    assert_response :success
    assert_template 'new'
  end

  def test_should_create_a_new_picture_record_on_POST_to_create
    assert_recognizes({ :controller => 'admin/pictures',
                        :action => 'create' },
                      :path => 'admin/pictures', :method => :post)

    old_count = Picture.count

    post :create, {
      :invoice_id => invoices(:company_one_vendor_one_this_month).id,
      :picture => {
        :uploaded_data => fixture_file_upload(File.join('pictures', 'image.jpg'), 'image/jpg')
      }
    }, :user_id => users(:user_one).id

    assert_equal old_count + 1, Picture.count
    assert_equal invoices(:company_one_vendor_one_this_month), assigns(:picture).subject
    assert_response :redirect
    assert_redirected_to admin_invoice_path(invoices(:company_one_vendor_one_this_month))
  end

  def test_should_not_create_pictures_for_empty_files_on_POST_to_create
    old_count = Picture.count

    post :create, {
      :invoice_id => invoices(:company_one_vendor_one_this_month).id,
      :picture => {
        :uploaded_data => ''
      }
    }, :user_id => users(:user_one).id

    assert_equal old_count, Picture.count
    assert_response :redirect
    assert_redirected_to admin_invoice_path(invoices(:company_one_vendor_one_this_month))
  end

  def test_should_delete_the_picture_record_with_the_given_id_on_DELETE_to_destroy
    assert_recognizes({ :controller => 'admin/pictures',
                        :action => 'destroy',
                        :id => '3' },
                      :path => 'admin/pictures/3', :method => :delete)
    picture = Picture.find(:all).detect do |each|
      ! each.subject.nil?
    end
    
    delete :destroy, { 
      :id => picture.id 
    }, :user_id => users(:user_one).id

    assert ! Picture.exists?(picture.id)
    assert_response :redirect
    assert_redirected_to admin_invoice_path(picture.subject)
  end

end
