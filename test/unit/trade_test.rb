require File.dirname(__FILE__) + '/../test_helper'

class TradeTest < Test::Unit::TestCase

  def test_should_be_associated_with_a_company
    trade = create_trade

    assert trade.respond_to?(:company)

    assert_raise(ActiveRecord::AssociationTypeMismatch) { trade.company = Organization.new }
  end

  def test_should_be_considered_invalid_when_missing_any_attribute_when_sent_valid?
    trade = Trade.new
    assert ! trade.valid?

    trade = Trade.new :direction => 'BUY'
    assert ! trade.valid?

    trade = Trade.new :quantity => 1000
    assert ! trade.valid?

    trade = Trade.new :symbol => 'IBM'
    assert ! trade.valid?

    trade = Trade.new :average_price => 25.555
    assert ! trade.valid?

    trade = Trade.new :made_on => Date.today
    assert ! trade.valid?

    trade = Trade.new :execution_type => 'BEST'
    assert ! trade.valid?

    trade = Trade.new :company => create_company
    assert ! trade.valid?

    trade = Trade.new :direction => 'BUY',
    :quantity => 1000,
    :symbol => 'IBM',
    :average_price => 25.50,
    :made_on => Date.today,
    :execution_type => 'BEST',
    :company => create_company
    assert trade.valid?
  end

  def test_should_be_considered_invalid_without_a_company_when_sent_valid?
    trade = Trade.new
    assert ! trade.valid?
    assert_not_nil trade.errors.on(:company_id)
  end

  def test_should_be_considered_invalid_if_its_quantity_is_not_an_integer_when_sent_valid?
    trade = Trade.new :quantity => 'quantity'
    assert ! trade.valid?
    assert_not_nil trade.errors.on(:quantity)

    trade.quantity = 1.1
    assert ! trade.valid?
    assert_not_nil trade.errors.on(:quantity)

    trade.quantity = 1
    assert ! trade.valid?
    assert_nil trade.errors.on(:quantity)
  end

  def test_should_be_considered_invalid_if_its_average_price_is_not_a_number_when_sent_valid?
    trade = Trade.new :average_price => 'average_price'
    assert ! trade.valid?
    assert_not_nil trade.errors.on(:average_price)

    trade.average_price = 10
    assert ! trade.valid?
    assert_nil trade.errors.on(:average_price)

    trade.average_price = 10.50
    assert ! trade.valid?
    assert_nil trade.errors.on(:average_price)
  end

  def test_should_be_considered_invalid_if_its_execution_type_is_not_BEST_or_SOFT_when_sent_valid?
    trade = create_trade
    trade.execution_type = 'execution_type'
    assert ! trade.valid?
    assert_not_nil trade.errors.on(:execution_type)

    trade.execution_type = 'BEST'
    assert trade.valid?

    trade.execution_type = 'SOFT'
    assert trade.valid?
  end

  def test_should_find_all_trades_made_within_the_given_time_span_and_trade_totals_when_sent_search_with_totals
    time_span = 2.weeks.ago.to_date..Date.today
    create_trade :made_on => time_span.begin + 1
    create_trade :made_on => time_span.begin + 2

    trades, totals = Trade.search_with_totals :time_span => time_span,
      :page => nil

    assert ! trades.empty?
    assert_kind_of WillPaginate::Collection, trades
    assert trades.size >= 2
    trades.each_with_index do |each, index|
      assert time_span.include?(each.made_on)
      if trades[index.succ]
        assert each.made_on <= trades[index.succ].made_on
      end
    end

    assert_equal '200', totals['quantity']
    assert_equal '0.0000', totals['credit_accrued']
    assert_equal '2.0000', totals['commission_paid']
  end

  def test_should_find_all_trades_made_within_the_given_time_span_of_the_given_execution_type_and_trade_totals_when_sent_search_with_totals
    time_span = 2.weeks.ago.to_date..Date.today
    create_soft_trade :made_on => time_span.begin
    create_soft_trade :made_on => time_span.begin + 1.day
    create_best_trade :made_on => time_span.begin
    create_best_trade :made_on => time_span.begin + 1.day

    trades, totals = Trade.search_with_totals :time_span => time_span,
      :execution_type => 'BEST',
      :page => nil

    assert ! trades.empty?
    assert_kind_of WillPaginate::Collection, trades
    trades.each do |each|
      assert time_span.include?(each.made_on)
      assert each.best?
    end

    assert_equal '100', totals['quantity']
    assert_equal '0.0000', totals['credit_accrued']
    assert_equal '1.0000', totals['commission_paid']
  end

  def test_should_say_its_a_soft_execution_type_trade_when_sent_soft?
    trade = create_soft_trade
    assert trade.soft?

    trade = create_best_trade
    assert ! trade.soft?
  end

  def test_should_say_its_a_best_execution_type_trade_when_sent_best?
    trade = create_best_trade
    assert trade.best?

    trade = create_soft_trade
    assert ! trade.best?
  end

  def test_should_calculate_and_set_its_credit_accrued_when_sent_save
    company = create_company
    trade = create_trade :direction => 'BUY',
      :quantity => 1000,
      :symbol => 'IBM',
      :average_price => 25.50,
      :made_on => Date.today,
      :execution_type => 'BEST',
      :company => company
    assert_equal 0, trade.credit_accrued

    trade = create_trade :direction => 'BUY',
      :quantity => 1000,
      :symbol => 'IBM',
      :average_price => 25.50,
      :made_on => Date.today,
      :execution_type => 'SOFT',
      :company => company
    assert_equal company.credit_rate * trade.quantity / 100,
      trade.credit_accrued
  end

  def test_should_calculate_and_set_its_commission_paid_when_sent_save
    company = create_company
    trade = create_trade :direction => 'BUY',
      :quantity => 1000,
      :symbol => 'IBM',
      :average_price => 25.50,
      :made_on => Date.today,
      :execution_type => 'BEST',
      :company => company
    assert_equal company.best_commission_rate * trade.quantity / 100,
      trade.commission_paid

    trade = create_trade :direction => 'BUY',
      :quantity => 1000,
      :symbol => 'IBM',
      :average_price => 25.50,
      :made_on => Date.today,
      :execution_type => 'SOFT',
      :company => company
    assert_equal company.soft_commission_rate * trade.quantity / 100, 
      trade.commission_paid
  end

  def test_should_be_considered_invalid_if_its_execution_type_is_not_BEST_or_SOFT_when_sent_valid?
    trade = create_trade
    trade.execution_type = 'execution_type'
    assert ! trade.valid?
    assert_not_nil trade.errors.on(:execution_type)

    trade.execution_type = 'BEST'
    assert trade.valid?

    trade.execution_type = 'SOFT'
    assert trade.valid?
  end

  def test_should_create_a_new_best_trade_from_the_given_array_parsed_from_a_best_trade_csv_string_when_sent_from_array
    array = '20090223,BRCM,Buy,1247530,15.9972,,ppeter'.split(',')

    trade = Trade.from_array array
    assert_equal Date.new(2009, 2, 23), trade.made_on
    assert_equal 'BRCM', trade.symbol
    assert_equal 'Buy', trade.direction
    assert_equal 1247530, trade.quantity
    assert_equal 15.9972, trade.average_price
    assert trade.best?
  end

  def test_should_create_a_new_soft_trade_from_the_given_array_parsed_from_a_soft_trade_csv_string_with_a_KAMASLOW_execution_type_value_when_sent_from_array
    array = '20090223,BRCM,Buy,1247530,15.9972,KAMASLOW,ppeter'.split(',')

    trade = Trade.from_array array
    assert_equal Date.new(2009, 2, 23), trade.made_on
    assert_equal 'BRCM', trade.symbol
    assert_equal 'Buy', trade.direction
    assert_equal 1247530, trade.quantity
    assert_equal 15.9972, trade.average_price
    assert trade.soft?
  end

  def test_should_create_a_new_soft_trade_from_the_given_array_parsed_from_a_soft_trade_csv_string_with_a_CSA_trader_value_when_sent_from_array
    array = '20090223,BRCM,Buy,1247530,15.9972,,CSA'.split(',')

    trade = Trade.from_array array
    assert_equal Date.new(2009, 2, 23), trade.made_on
    assert_equal 'BRCM', trade.symbol
    assert_equal 'Buy', trade.direction
    assert_equal 1247530, trade.quantity
    assert_equal 15.9972, trade.average_price
    assert trade.soft?
  end

  def test_should_create_a_new_soft_trade_from_the_given_array_parsed_from_a_soft_trade_csv_string_with_a_csa_trader_value_when_sent_from_array
    array = '20090223,BRCM,Buy,1247530,15.9972,,csa'.split(',')

    trade = Trade.from_array array
    assert_equal Date.new(2009, 2, 23), trade.made_on
    assert_equal 'BRCM', trade.symbol
    assert_equal 'Buy', trade.direction
    assert_equal 1247530, trade.quantity
    assert_equal 15.9972, trade.average_price
    assert trade.soft?
  end

  def test_should_create_a_new_soft_trade_from_the_given_array_parsed_from_an_soft_trade_csv_string_with_a_MELLON_execution_type_value_when_sent_from_array
    array = '20090223,BRCM,Buy,1247530,15.9972,MELLON,ppeter'.split(',')

    trade = Trade.from_array array
    assert_equal Date.new(2009, 2, 23), trade.made_on
    assert_equal 'BRCM', trade.symbol
    assert_equal 'Buy', trade.direction
    assert_equal 1247530, trade.quantity
    assert_equal 15.9972, trade.average_price
    assert trade.soft?
  end

  def test_should_say_if_its_an_auto_trade_when_sent_auto?
    trade = create_best_trade
    assert ! trade.auto?

    trade = create_auto_trade
    assert trade.auto?
  end

end
