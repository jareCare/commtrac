class CreateTrades < ActiveRecord::Migration
  def self.up
    create_table :trades do |t|
      t.column :direction, :string
      t.column :quantity, :integer
      t.column :symbol, :string
      t.column :average_price, :float
      t.column :made_on, :date
      t.column :execution_type, :string
      t.column :company_id, :integer
    end
  end

  def self.down
    drop_table :trades
  end
end
