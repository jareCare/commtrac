class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.column :first_name, :string
      t.column :last_name, :string
      t.column :email, :string
      t.column :password, :string
      t.column :phone_number, :string
      t.column :admin, :boolean
      t.column :created_on, :datetime
      t.column :company_id, :integer
    end
  end

  def self.down
    drop_table :users
  end
end
