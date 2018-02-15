require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/trades_controller'

# Re-raise errors caught by the controller.
class Admin::TradesController; def rescue_action(e) raise e end; end

class Admin::TradesControllerTest < Test::Unit::TestCase

  fixtures :trades, :users, :companies

  def setup
    @controller = Admin::TradesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login_as_admin
  end

  def login_as_admin
    get :search, {}, :user_id => users(:user_one).id
  end

  def test_should_find_the_trade_record_with_the_given_id_on_GET_to_edit
    assert_recognizes({ :controller => 'admin/trades',
                        :action => 'edit',
                        :id => '2' },
                      :path => 'admin/trades/2;edit', :method => :get)

    get :edit, :id => trades(:company_one_ibm).id

    assert_equal trades(:company_one_ibm), assigns(:trade)
    assert_response :success
    assert_template 'edit'
  end

  def test_should_update_the_trade_record_with_the_given_id_on_PUT_to_update
    assert_recognizes({ :controller => 'admin/trades',
                        :action => 'update',
                        :id => '2' },
                      :path => 'admin/trades/2', :method => :put)

    put :update, :id => trades(:company_one_ibm).id,
    :trade => { :execution_type => 'SOFT' }

    trades(:company_one_ibm).reload
    assert_equal 'SOFT', trades(:company_one_ibm).execution_type
    assert_response :redirect
    assert_redirected_to admin_trade_path(trades(:company_one_ibm))
  end

  def test_should_not_update_the_trade_record_to_an_invalid_state_on_PUT_to_update
    Trade.any_instance.expects(:update_attributes).returns false

    put :update, :id => trades(:company_one_ibm).id,
    :trade => {}

    assert_response :success
    assert_template 'edit'
  end

  def test_should_find_the_trade_record_with_the_given_id_on_GET_to_show
    assert_recognizes({ :controller => 'admin/trades',
                        :action => 'show',
                        :id => '2' },
                      :path => 'admin/trades/2', :method => :get)

    get :show, :id => trades(:company_one_ibm).id

    assert_equal trades(:company_one_ibm), assigns(:trade)
    assert_response :success
    assert_template 'show'
  end

  def test_should_render_the_search_form_when_not_given_a_start_and_end_date_on_GET_to_search
    get :search

    assert_nil assigns(:start_date)
    assert_nil assigns(:end_date)
    assert_nil assigns(:trades)
    assert_response :success
    assert_template 'search'
  end

  def test_should_render_the_search_form_when_given_an_invalid_start_date_on_GET_to_search
    get :search, :start_date => {
        :year => '2007',
        :month => '01',
        :day => '35' },
      :end_date => { 
        :year => '2007',
        :month => '01',
        :day => '01' }
    
    assert_response :success
    assert_template 'search'
    assert_select 'p#flash', /please/i
  end

  def test_should_render_the_search_form_when_given_an_invalid_end_date_on_GET_to_search
    get :search, :start_date => {
        :year => '2007',
        :month => '01',
        :day => '01' },
      :end_date => { 
        :year => '2007',
        :month => '01',
        :day => '35' }
    
    assert_response :success
    assert_template 'search'
    assert_select 'p#flash', /please/i
  end

  def test_should_render_the_search_form_when_given_an_invalid_start_and_end_date_on_GET_to_search
    get :search, :start_date => {
        :year => '2007',
        :month => '01',
        :day => '35' },
      :end_date => { 
        :year => '2007',
        :month => '01',
        :day => '35' }
    
    assert_response :success
    assert_template 'search'
    assert_select 'p#flash', /please/i
  end

  def test_should_render_the_search_form_when_given_just_a_start_date_on_GET_to_search
    get :search, { :start_date => {
      :year => Date.today.year.to_s,
      :month => Date.today.month.to_s,
      :day => Date.today.day.to_s } }, 
    :user_id => users(:user_two).id

    assert_nil assigns(:start_date)
    assert_nil assigns(:end_date)
    assert_nil assigns(:trades)
    assert_response :success
    assert_template 'search'
  end

  def test_should_render_the_search_form_when_given_just_an_end_date_on_GET_to_search
    get :search, :end_date => {
      :year => Date.today.year.to_s,
      :month => Date.today.month.to_s,
      :day => Date.today.day.to_s }

    assert_nil assigns(:start_date)
    assert_nil assigns(:end_date)
    assert_nil assigns(:trades)
    assert_response :success
    assert_template 'search'
  end

  def test_should_find_all_trades_made_by_the_given_company_in_the_given_time_span_and_trade_totals_on_GET_to_search
    start_date = Time.now.beginning_of_month.to_date
    end_date = Time.now.end_of_month.to_date

    get :search, { 
      :company_id => companies(:company_one).id,
      :start_date => { 
        :year => start_date.year.to_s,
        :month => start_date.month.to_s,
        :day => start_date.day.to_s },
      :end_date => {
        :year => end_date.year.to_s,
        :month => end_date.month.to_s,
        :day => end_date.day.to_s },
      :execution_type => 'All' },
    :user_id => users(:user_one).id

    assert_equal start_date, assigns(:start_date)
    assert_equal end_date, assigns(:end_date)
    assert_equal companies(:company_one), assigns(:company)
    assert_equal companies(:company_one).trades.search_with_totals(:time_span => start_date..end_date)[0],
      assigns(:trades)
    assert_not_nil assigns(:totals)
    assert_not_nil assigns(:totals)['quantity']
    assert_not_nil assigns(:totals)['credit_accrued']
    assert_not_nil assigns(:totals)['commission_paid']
    assert_response :success
    assert_template 'search'
  end

  def test_should_find_all_trades_made_by_the_given_company_in_the_given_time_span_of_the_given_execution_type_and_trade_totals_on_GET_to_search
    start_date = Time.now.beginning_of_month.to_date
    end_date = Time.now.end_of_month.to_date

    get :search, { 
      :company_id => companies(:company_one).id,
      :start_date => { 
        :year => start_date.year.to_s,
        :month => start_date.month.to_s,
        :day => start_date.day.to_s 
      },
      :end_date => {
        :year => end_date.year.to_s,
        :month => end_date.month.to_s,
        :day => end_date.day.to_s 
      },
      :execution_type => 'BEST'
    }, :user_id => users(:user_two).id

    assert_equal start_date, assigns(:start_date)
    assert_equal end_date, assigns(:end_date)
    assert_equal companies(:company_one), assigns(:company)
    assert_equal companies(:company_one).trades.search_with_totals(:time_span => start_date..end_date,
                                                                   :execution_type => 'BEST')[0],
      assigns(:trades)
    assert_not_nil assigns(:totals)
    assert_not_nil assigns(:totals)['quantity']
    assert_not_nil assigns(:totals)['credit_accrued']
    assert_not_nil assigns(:totals)['commission_paid']
    assert_response :success
    assert_template 'search'
  end

  def test_should_create_a_new_trade_object_on_GET_to_new
    assert_recognizes({ :controller => 'admin/trades',
                        :action => 'new' },
                      :path => 'admin/trades/new', :method => :get)
    get :new

    assert_kind_of Trade, assigns(:trade)
    assert_response :success
    assert_template 'new'
  end

  def test_should_create_a_new_trade_record_on_POST_to_create
    assert_recognizes({ :controller => 'admin/trades',
                        :action => 'create' },
                      :path => 'admin/trades', :method => :post)

    post :create, :trade => { 
      :direction => 'Buy',
      :quantity => '1000',
      :symbol => 'IBM',
      :average_price => '25.4444',
      'made_on(1i)' => '2007',
      'made_on(2i)' => '4',
      'made_on(3i)' => '1',
      :execution_type => 'SOFT',
      :company_id => companies(:company_one).id
    }

    assert Trade.find(:first,
                      :conditions => ['symbol = ? and quantity = ?',
                        'IBM', 1000])
    assert_response :redirect
    assert_redirected_to admin_trade_path(assigns(:trade))
  end

  def test_should_not_create_a_new_trade_record_on_POST_to_create
    post :create, :trade => {}

    assert ! assigns(:trade).valid?
    assert_response :success
    assert_template 'new'
  end

  def test_should_delete_the_trade_record_with_the_given_id_on_DELETE_to_destroy
    assert_recognizes({ :controller => 'admin/trades',
                        :action => 'destroy',
                        :id => '1' },
                      :path => 'admin/trades/1', :method => :delete)

    delete :destroy, :id => trades(:company_one_ibm).id

    assert ! Trade.exists?(trades(:company_one_ibm).id)
    assert_response :redirect
    assert_redirected_to admin_trades_path
  end

end

