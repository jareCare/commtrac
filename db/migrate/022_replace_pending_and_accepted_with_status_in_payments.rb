class ReplacePendingAndAcceptedWithStatusInPayments < ActiveRecord::Migration
  def self.up
    add_column :payments, :status, :string

    payments = select_all 'select * from payments'
    payments.each do |each|
      if ! each['processed_on'].nil?
        status = 'Processed'
      elsif each['pending'] == '1' &&
          each['accepted'] == '1'
        status = 'Accepted'
      elsif each['pending'] == '0' &&
          each['accepted'] == '0'
        status = 'Rejected'
      else
        status = 'Pending'
      end
      update "update payments
                 set status = '#{status}'
               where id = #{each['id']}"
    end

    remove_column :payments, :pending
    remove_column :payments, :accepted
  end

  def self.down
    add_column :payments, :pending, :boolean, :default => true
    add_column :payments, :accepted, :boolean

    payments = select_all 'select * from payments'
    payments.each do |each|
      if each['status'] == 'Processed' ||
          each['status'] == 'Accepted'
        update "update payments
                   set pending = true,
                       accepted = true
                 where id = #{each['id']}"
      elsif each['status'] == 'Rejected'
        update "update payments
                   set pending = false,
                       accepted = false
                 where id = #{each['id']}"
      else
        update "update payments
                   set pending = true
                 where id = #{each['id']}"
      end
    end

    remove_column :payments, :status
  end
end
