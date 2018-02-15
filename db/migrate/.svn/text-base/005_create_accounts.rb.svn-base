class CreateAccounts < ActiveRecord::Migration
  def self.up
    create_table :accounts do |t|
      t.column :number, :string
      t.column :created_on, :datetime
      t.column :company_id, :integer
      t.column :vendor_id, :integer
    end
  end

  def self.down
    drop_table :accounts
  end
end
