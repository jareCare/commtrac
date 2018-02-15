class CreatePayments < ActiveRecord::Migration
  def self.up
    create_table :payments do |t|
      t.column :amount, :float
      t.column :created_on, :datetime
      t.column :updated_on, :datetime
      t.column :request, :text
      t.column :response, :text
      t.column :pending, :boolean, :default => true
      t.column :accepted, :boolean
      t.column :user_id, :integer
      t.column :account_id, :integer
    end
  end

  def self.down
    drop_table :payments
  end
end
