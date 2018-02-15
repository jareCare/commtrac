class RemoveBalanceAndTotalColumnsFromCompanies < ActiveRecord::Migration
  def self.up
    remove_column :companies, :credit_balance
    remove_column :companies, :credits_accrued_mtd
    remove_column :companies, :credits_accrued_ytd
    remove_column :companies, :best_commission_paid_mtd
    remove_column :companies, :best_commission_paid_ytd
    remove_column :companies, :soft_commission_paid_mtd
    remove_column :companies, :soft_commission_paid_ytd
    remove_column :companies, :commission_paid_mtd
    remove_column :companies, :commission_paid_ytd
    remove_column :companies, :credits_accrued
    remove_column :companies, :best_commission_paid
    remove_column :companies, :soft_commission_paid
    remove_column :companies, :commission_paid
  end

  def self.down
    add_column :companies, :credit_balance, :decimal,  :precision => 63, :scale => 4, :default => 0.0
    add_column :companies, :credits_accrued_mtd, :decimal,  :precision => 63, :scale => 4, :default => 0.0
    add_column :companies, :credits_accrued_ytd, :decimal,  :precision => 63, :scale => 4, :default => 0.0
    add_column :companies, :best_commission_paid_mtd, :decimal,  :precision => 63, :scale => 4, :default => 0.0
    add_column :companies, :best_commission_paid_ytd, :decimal,  :precision => 63, :scale => 4, :default => 0.0
    add_column :companies, :soft_commission_paid_mtd, :decimal,  :precision => 63, :scale => 4, :default => 0.0
    add_column :companies, :soft_commission_paid_ytd, :decimal,  :precision => 63, :scale => 4, :default => 0.0
    add_column :companies, :commission_paid_mtd, :decimal,  :precision => 63, :scale => 4, :default => 0.0
    add_column :companies, :commission_paid_ytd, :decimal,  :precision => 63, :scale => 4, :default => 0.0
    add_column :companies, :credits_accrued, :decimal,  :precision => 63, :scale => 4, :default => 0.0
    add_column :companies, :best_commission_paid, :decimal,  :precision => 63, :scale => 4, :default => 0.0
    add_column :companies, :soft_commission_paid, :decimal,  :precision => 63, :scale => 4, :default => 0.0
    add_column :companies, :commission_paid, :decimal,  :precision => 63, :scale => 4, :default => 0.0
  end
end
