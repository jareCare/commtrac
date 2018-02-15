require File.dirname(__FILE__) + '/../test_helper'
require 'trades_controller'

# Re-raise errors caught by the controller.
class TradesController; def rescue_action(e) raise e end; end

class TradesControllerTest < Test::Unit::TestCase

  fixtures :users, :companies

  def setup
    @controller = TradesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_render_the_index_view_when_not_given_a_start_and_end_date_on_GET_to_index
    assert_recognizes({ :controller => 'trades',
                        :action => 'index',
                        :company_id => '1' },
                      :path => 'companies/1/trades', :method => :get)

    get :index, {
      :company_id => users(:user_two).company.id
    }, :user_id => users(:user_two).id

    assert_equal users(:user_two).company, assigns(:company)
    assert_nil assigns(:start_date)
    assert_nil assigns(:end_date)
    assert_nil assigns(:trades)
    assert_response :success
    assert_template 'index'
  end

  def test_should_render_the_index_view_when_given_an_invalid_start_date_on_GET_to_index
    get :index, { 
      :company_id => users(:user_two).company.id,
      :start_date => {
        :year => '2007',
        :month => '01',
        :day => '35' 
      },
      :end_date => { 
        :year => '2007',
        :month => '01',
        :day => '01' 
      } 
    }, :user_id => users(:user_two).id
    
    assert_response :success
    assert_template 'index'
    assert_select 'p#flash', /please/i
  end

  def test_should_render_the_index_view_when_given_an_invalid_end_date_on_GET_to_index
    get :index, { 
      :company_id => users(:user_two).company.id,
      :start_date => {
        :year => '2007',
        :month => '01',
        :day => '01' 
      },
      :end_date => { 
        :year => '2007',
        :month => '01',
        :day => '35' 
      } 
    }, :user_id => users(:user_two).id
    
    assert_response :success
    assert_template 'index'
    assert_select 'p#flash', /please/i
  end

  def test_should_render_the_index_view_when_given_an_invalid_start_and_end_date_on_GET_to_index
    get :index, { 
      :company_id => users(:user_two).company.id,
      :start_date => {
        :year => '2007',
        :month => '01',
        :day => '35' 
      },
      :end_date => { 
        :year => '2007',
        :month => '01',
        :day => '35' 
      } 
    }, :user_id => users(:user_two).id
    
    assert_response :success
    assert_template 'index'
    assert_select 'p#flash', /please/i
  end

  def test_should_render_the_index_view_when_given_just_a_start_date_on_GET_to_index
    get :index, { 
      :company_id => users(:user_two).company.id,
      :start_date => {
      :year => Date.today.year.to_s,
      :month => Date.today.month.to_s,
      :day => Date.today.day.to_s 
      } 
    }, :user_id => users(:user_two).id

    assert_nil assigns(:start_date)
    assert_nil assigns(:end_date)
    assert_nil assigns(:trades)
    assert_response :success
    assert_template 'index'
  end

  def test_should_render_the_index_view_when_given_just_an_end_date_on_GET_to_index
    get :index, { 
      :company_id => users(:user_two).company.id,
      :end_date => {
        :year => Date.today.year.to_s,
        :month => Date.today.month.to_s,
        :day => Date.today.day.to_s 
      } 
    }, :user_id => users(:user_two).id

    assert_nil assigns(:start_date)
    assert_nil assigns(:end_date)
    assert_nil assigns(:trades)
    assert_response :success
    assert_template 'index'
  end

  def test_should_find_all_trades_made_by_the_current_users_company_made_in_the_given_time_span_and_trade_totals_on_GET_to_index
    start_date = Time.now.beginning_of_month.to_date
    end_date = Time.now.end_of_month.to_date

    get :index, { 
      :company_id => users(:user_two).company.id,
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
      :execution_type => 'All' 
    }, :user_id => users(:user_one).id

    assert_equal start_date, assigns(:start_date)
    assert_equal end_date, assigns(:end_date)
    assert_equal users(:user_one).company.trades.search_with_totals(:time_span => start_date..end_date)[0],
      assigns(:trades)
    assert_not_nil assigns(:totals)
    assert_not_nil assigns(:totals)['quantity']
    assert_not_nil assigns(:totals)['credit_accrued']
    assert_not_nil assigns(:totals)['commission_paid']
    assert_response :success
    assert_template 'index'
  end

  def test_should_find_all_trades_made_by_the_current_users_company_made_in_the_given_time_span_of_the_given_execution_type_and_trade_totals_on_GET_to_index
    start_date = Time.now.beginning_of_month.to_date
    end_date = Time.now.end_of_month.to_date
    get :index, { 
      :company_id => users(:user_two).company.id,
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
    assert_equal users(:user_one).company.trades.search_with_totals(:time_span => start_date..end_date,
                                                                    :execution_type => 'BEST')[0],
      assigns(:trades)
    assert_not_nil assigns(:totals)
    assert_not_nil assigns(:totals)['quantity']
    assert_not_nil assigns(:totals)['credit_accrued']
    assert_not_nil assigns(:totals)['commission_paid']
    assert_response :success
    assert_template 'index'
  end

end

