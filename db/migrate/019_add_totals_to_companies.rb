class AddTotalsToCompanies < ActiveRecord::Migration
  def self.up
    add_column :companies, :credits_accrued, :decimal, 
	:precision => 63, :scale => 4, :default => 0.0
    add_column :companies, :best_commission_paid, :decimal, 
	:precision => 63, :scale => 4, :default => 0.0
    add_column :companies, :soft_commission_paid, :decimal, 
	:precision => 63, :scale => 4, :default => 0.0
    add_column :companies, :commission_paid, :decimal, 
	:precision => 63, :scale => 4, :default => 0.0
  end

  def self.down
    remove_column :companies, :credits_accrued
    remove_column :companies, :best_commission_paid
    remove_column :companies, :soft_commission_paid
    remove_column :companies, :commission_paid
  end
end
