class AddFalseDefaultToBrokerInVendors < ActiveRecord::Migration
  def self.up
    change_column :vendors, :broker, :boolean, :default => false
  end

  def self.down
    change_column :vendors, :broker, :boolean, :default => nil
  end
end
