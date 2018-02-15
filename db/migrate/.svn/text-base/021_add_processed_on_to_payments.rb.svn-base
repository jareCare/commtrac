class AddProcessedOnToPayments < ActiveRecord::Migration
  def self.up
    add_column :payments, :processed_on, :date

    payments = select_all 'select * from payments'
    payments.each do |payment|
      total_invoiced_amount = select_value "select sum(amount) 
                                              from invoices
                                             where payment_id = #{payment['id']}"
      if total_invoiced_amount.to_f == payment['amount'].to_f
        latest_invoice = select_one "select *
                                       from invoices
                                      where payment_id = #{payment['id']}
                                      order by created_on desc
                                      limit 1"
        update "update payments
                   set processed_on = '#{latest_invoice['created_on']}'
                 where id = #{payment['id']}"
      end
    end
  end

  def self.down
    remove_column :payments, :processed_on
  end
end
