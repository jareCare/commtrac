class CreateVendors < ActiveRecord::Migration
  def self.up
    create_table :vendors do |t|
      t.column :name, :string
      t.column :broker, :boolean
      t.column :street, :string
      t.column :city, :string
      t.column :state, :string
      t.column :zipcode, :string
      t.column :contact, :string
      t.column :email, :string
      t.column :phone_number, :string
      t.column :terms, :text
      t.column :notes, :text
      t.column :created_on, :datetime
    end
  end

  def self.down
    drop_table :vendors
  end
end
