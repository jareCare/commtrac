class AddForeignKeyIndexes < ActiveRecord::Migration
  def self.up
    add_index :accounts, :company_id, :name => 'accounts_company_id_index'
    add_index :accounts, :vendor_id, :name => 'accounts_vendor_id_index'
    add_index :accounts, [:company_id, :vendor_id], :unqiue => true,
     :name => 'accounts_company_id_vendor_id'

    add_index :invoices, :payment_id, :name =>'invoices_payment_id_index'

    add_index :payments, :user_id, :name => 'payments_user_id_index'
    add_index :payments, :account_id, :name => 'payments_account_id_index'

    add_index :pictures, [:subject_id, :subject_type], :unique => true

    add_index :trades, :company_id, :name => 'trades_company_id_index'

    add_index :users, :company_id, :name => 'users_company_id_index'
  end

  def self.down
    remove_index :accounts, :name => 'accounts_company_id_index'
    remove_index :accounts, :name => 'accounts_vendor_id_index'
    remove_index :accounts, :name => 'accounts_company_id_vendor_id'

    remove_index :invoices, :name => 'invoices_payment_id_index'

    remove_index :payments, :name => 'payments_user_id_index'
    remove_index :payments, :name => 'payments_account_id_index'

    remove_index :pictures, [:subject_id, :subject_type]

    remove_index :trades, :name => 'trades_company_id_index'

    remove_index :users, :name => 'users_company_id_index'
  end
end
