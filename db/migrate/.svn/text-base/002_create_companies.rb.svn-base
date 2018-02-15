class CreateCompanies < ActiveRecord::Migration
  def self.up
    create_table :companies do |t|
      t.column :name, :string
      t.column :street, :string
      t.column :city, :string
      t.column :state, :string
      t.column :zipcode, :string
      t.column :phone_number, :string
      t.column :web_site, :string
      t.column :credit_rate, :float
      t.column :best_commission_rate, :float
      t.column :soft_commission_rate, :float
      t.column :credit_balance, :float, :default => 0
      t.column :credits_accrued_mtd, :float, :default => 0
      t.column :credits_accrued_ytd, :float, :default => 0
      t.column :best_commission_paid_mtd, :float, :default => 0.0
      t.column :soft_commission_paid_mtd, :float, :default => 0.0
      t.column :best_commission_paid_ytd, :float, :default => 0.0
      t.column :soft_commission_paid_ytd, :float, :default => 0.0
      t.column :commission_paid_mtd, :float, :default => 0.0
      t.column :commission_paid_ytd, :float, :default => 0.0
      t.column :created_on, :datetime
    end
  end

  def self.down
    drop_table :companies
  end
end
