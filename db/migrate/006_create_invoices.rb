class CreateInvoices < ActiveRecord::Migration
  def self.up
    create_table :invoices do |t|
      t.column :number, :string
      t.column :amount, :float
      t.column :start_date, :date
      t.column :end_date, :date
      t.column :check_number, :integer
      t.column :paid_on, :date
      t.column :notes, :text
      t.column :created_on, :datetime
      t.column :payment_id, :integer
    end
  end

  def self.down
    drop_table :invoices
  end
end
