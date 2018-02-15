class AddCreditAccruedAndCommissionPaidToTrades < ActiveRecord::Migration
  def self.up
    add_column :trades, :credit_accrued, :float
    add_column :trades, :commission_paid, :float

    trades = select_all 'select * from trades'
    trades.each do |each|
      company = select_one "select * from companies where id = #{each['company_id']}"
      if each['execution_type'] == 'SOFT'
        update 'update trades ' +
          "set credit_accrued = #{company['credit_rate'].to_f * each['quantity'].to_f / 100}, " +
              "commission_paid = #{company['soft_commission_rate'].to_f * each['quantity'].to_f / 100} " +
              "where id = #{each['id']}"
      else
        update 'update trades ' +
          'set credit_accrued = 0.0, ' +
              "commission_paid = #{company['best_commission_rate'].to_f * each['quantity'].to_f / 100} " +
              "where id = #{each['id']}"
      end
    end
  end

  def self.down
    remove_column :trades, :credit_accrued
    remove_column :trades, :commission_paid
  end
end
