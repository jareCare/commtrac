require File.dirname(__FILE__) + '/../test_helper'
require 'invoices_controller'

# Re-raise errors caught by the controller.
class InvoicesController; def rescue_action(e) raise e end; end

class InvoicesControllerTest < Test::Unit::TestCase

  fixtures :invoices, 
    :users, 
    :organizations, 
    :companies, 
    :accounts, 
    :payments

  def setup
    @controller = InvoicesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_render_the_index_view_when_not_given_a_start_and_end_date_and_vendor_on_GET_to_index
    assert_recognizes({ :controller => 'invoices',
                        :action => 'index',
                        :company_id => '2' },
                      :path => 'companies/2/invoices', :method => :get)

    get :index, {
      :company_id => users(:user_two).company.id
    }, :user_id => users(:user_two).id

    assert_equal users(:user_two).company, assigns(:company)
    assert_nil assigns(:start_date)
    assert_nil assigns(:end_date)
    assert_nil assigns(:vendor)
    assert_nil assigns(:invoices)
    assert_response :success
    assert_template 'index'
  end

  def test_should_render_the_index_view_when_given_an_invalid_start_date_on_GET_to_index
    get :index, { 
      :company_id => users(:user_two).company.id,
      :start_date => {
        :year => '2007',
        :month => '01',
        :day => '35' },
      :end_date => { 
        :year => '2007',
        :month => '01',
        :day => '01' } },
    :user_id => users(:user_two).id
    
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
        :day => '01' },
      :end_date => { 
        :year => '2007',
        :month => '01',
        :day => '35' } },
    :user_id => users(:user_two).id
    
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
        :day => '35' },
      :end_date => { 
        :year => '2007',
        :month => '01',
        :day => '35' } },
    :user_id => users(:user_two).id
    
    assert_response :success
    assert_template 'index'
    assert_select 'p#flash', /please/i
  end

  def test_should_render_the_index_view_when_given_an_empty_start_and_or_end_date_and_vendor_on_GET_to_index
    get :index, { 
      :company_id => users(:user_two).company.id,
      :start_date => { 
        :day => nil, 
        :month => nil, 
        :year => nil 
      } 
    }, :user_id => users(:user_two).id

    assert_nil assigns(:start_date)
    assert_nil assigns(:end_date)
    assert_nil assigns(:vendor)
    assert_nil assigns(:invoices)
    assert_response :success
    assert_template 'index'

    get :index, { 
      :company_id => users(:user_two).company.id,      
      :end_date => { 
        :day => nil, 
        :month => nil, 
        :year => nil 
      } 
    }, :user_id => users(:user_two).id

    assert_nil assigns(:start_date)
    assert_nil assigns(:end_date)
    assert_nil assigns(:vendor)
    assert_nil assigns(:invoices)
    assert_response :success
    assert_template 'index'

    get :index, { 
      :company_id => users(:user_two).company.id,
      :start_date => { 
        :day => nil, 
        :month => nil, 
        :year => nil 
      }, 
      :end_date => { 
        :day => nil, 
        :month => nil, 
        :year => nil 
      } 
    }, :user_id => users(:user_two).id

    assert_nil assigns(:start_date)
    assert_nil assigns(:end_date)
    assert_nil assigns(:vendor)
    assert_nil assigns(:invoices)
    assert_response :success
    assert_template 'index'
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
    assert_nil assigns(:vendor)
    assert_nil assigns(:invoices)
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
    assert_nil assigns(:vendor)
    assert_nil assigns(:invoices)
    assert_response :success
    assert_template 'index'
  end

  def test_should_index_for_all_invoices_within_the_given_time_span_for_accounts_from_the_current_users_company_to_the_given_organization_on_GET_to_index
    get :index, { 
      :company_id => users(:user_two).company.id,
      :start_date => { 
        :year => 1.month.ago.to_date.year.to_s,
        :month => 1.month.ago.to_date.month.to_s, 
        :day => 1.month.ago.to_date.day.to_s },
      :end_date => {
        :year => 1.month.from_now.to_date.year.to_s,
        :month => 1.month.from_now.to_date.month.to_s,
        :day => 1.month.from_now.to_date.day.to_s },
      :organization_id => organizations(:vendor_one).id },
    :user_id => users(:user_two).id

    assert_equal 1.month.ago.to_date, assigns(:start_date)
    assert_equal 1.month.from_now.to_date, assigns(:end_date)
    assert_equal organizations(:vendor_one), assigns(:organization)
    assert_equal Invoice.search(users(:user_two).company,
                                :time_span => (1.month.ago.to_date)..(1.month.from_now.to_date),
                                :vendors => [organizations(:vendor_one)]),
    assigns(:invoices)
    assert_response :success
    assert_template 'index'
  end

  def test_should_find_the_invoice_record_with_the_given_id_on_GET_to_show
    assert_recognizes({ :controller => 'invoices',
                        :action => 'show',
                        :company_id => '3',
                        :id => '3' },
                      :path => 'companies/3/invoices/3', :method => :get)

    get :show, { 
      :company_id => users(:user_two).company.id,
      :id => invoices(:company_one_vendor_one_this_month).id 
    }, :user_id => users(:user_two).id

    assert_equal users(:user_two).company, assigns(:company)
    assert_equal invoices(:company_one_vendor_one_this_month), assigns(:invoice)
    assert_response :success
    assert_template 'show'
  end

  def test_should_find_all_invoices_made_on_accounts_belonging_to_the_organization_with_the_given_id_on_GET_to_index
    start_date = 1.month.ago
    end_date = 1.month.from_now
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
      :organization_id => organizations(:vendor_one).id 
    }, :user_id => users(:user_two).id

    assert_equal Invoice.search(users(:user_two).company,
                                :vendors => [organizations(:vendor_one)],
                                :time_span => start_date..end_date),
    assigns(:invoices)
    assert_response :success
    assert_template 'index'
  end

  def test_should_search_for_invoices_by_broker_or_vendor_when_given_both_a_broker_and_a_vendor_of_all_on_GET_to_index
    start_date = 1.month.ago
    end_date = 1.month.from_now
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
      :organization_id => 'All' 
    }, :user_id => users(:user_two).id

    assert_equal 'All', assigns(:vendors)
    assert_equal 'All', assigns(:brokers)
    assert_equal Invoice.search(users(:user_two).company,
                                :vendors => Organization.find(:all,
                                                              :conditions => 'organization_type = "Vendor"'),
                                :brokers => Organization.find(:all,
                                                              :conditions => 'organization_type = "Broker"'),
                                :time_span => start_date..end_date),
    assigns(:invoices)
    assert_response :success
    assert_template 'index'
  end

  def test_should_search_for_invoices_by_all_organizations_when_sent_all_vendors_on_GET_to_index
    start_date = 1.month.ago
    end_date = 1.month.from_now
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
      :organization_id => 'All Vendors' 
    }, :user_id => users(:user_two).id

    assert_equal 'All', assigns(:vendors)
    assert_equal Invoice.search(users(:user_two).company,
                                :vendors => users(:user_two).company.organizations.reject {|each| each.broker?},
                                :time_span => start_date..end_date),
    assigns(:invoices)
    assert_response :success
    assert_template 'index'
  end

  def test_should_search_for_invoices_by_all_brokers_when_sent_all_brokers_on_GET_to_index
    start_date = 1.month.ago
    end_date = 1.month.from_now
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
      :organization_id => 'All Brokers' 
    }, :user_id => users(:user_two).id

    assert_equal 'All', assigns(:brokers)
    assert_equal Invoice.search(users(:user_two).company,
                                :brokers => users(:user_two).company.organizations.select {|each| each.broker?},
                                :time_span => start_date..end_date),
    assigns(:invoices)
    assert_response :success
    assert_template 'index'
  end

  def test_should_find_all_invoices_for_the_broker_with_the_given_id_on_GET_to_index
    Payment.delete_all
    company = companies :company_one
    5.times do 
      company.trades.create! :direction => 'BUY',
        :quantity => 100,
        :symbol => 'MSFT',
        :average_price => 100.0,
        :made_on => Date.today,
        :execution_type => 'SOFT'
    end

    PDF::Writer.
      any_instance.
      expects(:image)

    payment = Payment.create! :user => users(:user_two),
      :account => accounts(:company_one_vendor_one),
      :amount => 2.00

    invoice = Invoice.create! :payment => payment,
      :number => '1',
      :amount => 1.00,
      :start_date => Date.today,
      :end_date => Date.today,
      :check_number => 1,
      :paid_on => Date.today

    assert organizations(:vendor_one).update_attribute(:organization_type, 'Broker')

    get :index, {
      :company_id => users(:user_two).company.id,
      :start_date => { 
        :year => 1.month.ago.to_date.year.to_s,
        :month => 1.month.ago.to_date.month.to_s, 
        :day => 1.month.ago.to_date.day.to_s 
      },
      :end_date => {
        :year => 1.month.from_now.to_date.year.to_s,
        :month => 1.month.from_now.to_date.month.to_s,
        :day => 1.month.from_now.to_date.day.to_s 
      },
      :organization_id => organizations(:vendor_one).id
    }, :user_id => users(:user_two).id

    assert ! assigns(:invoices).empty?
    assert assigns(:invoices).all? {|each| each.payment.account.organization == organizations(:vendor_one)}
  end

  def test_should_find_all_invoices_for_the_vendor_with_the_given_id_on_GET_to_index
    Payment.delete_all
    company = companies :company_one
    5.times do 
      company.trades.create! :direction => 'BUY',
        :quantity => 100,
        :symbol => 'MSFT',
        :average_price => 100.0,
        :made_on => Date.today,
        :execution_type => 'SOFT'
    end

    PDF::Writer.
      any_instance.
      expects(:image)

    payment = Payment.create! :user => users(:user_two),
      :account => accounts(:company_one_vendor_one),
      :amount => 2.00

    invoice = Invoice.create! :payment => payment,
      :number => '1',
      :amount => 1.00,
      :start_date => Date.today,
      :end_date => Date.today,
      :check_number => 1,
      :paid_on => Date.today
    assert organizations(:vendor_one).update_attribute(:organization_type, 'Broker')

    get :index, {
      :company_id => users(:user_two).company.id,
      :start_date => { 
        :year => 1.month.ago.to_date.year.to_s,
        :month => 1.month.ago.to_date.month.to_s, 
        :day => 1.month.ago.to_date.day.to_s 
      },
      :end_date => {
        :year => 1.month.from_now.to_date.year.to_s,
        :month => 1.month.from_now.to_date.month.to_s,
        :day => 1.month.from_now.to_date.day.to_s 
      },
      :organization_id => organizations(:vendor_one).id
    }, :user_id => users(:user_two).id

    assert ! assigns(:invoices).empty?
    assert assigns(:invoices).all? {|each| each.payment.account.organization == organizations(:vendor_one)}
  end

end
