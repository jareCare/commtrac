class AddSearchIndexes < ActiveRecord::Migration
  def self.up
    add_index :users, [:email, :password], :name => 'users_email_index'

    add_index :invoices, :paid_on, :name => 'invoices_paid_on_index'

    add_index :trades, :made_on, :name => 'trades_made_on_index'
    add_index :trades, :execution_type, :name => 'trades_execution_type_index'
  end

  def self.down
    remove_index :users, :name => 'users_email_index'

    remove_index :invoices, :name => 'invoices_paid_on_index'

    remove_index :trades, :name => 'trades_made_on_index'
    remove_index :trades, :name => 'trades_execution_type_index'
  end
end
