class RemoveReasons < ActiveRecord::Migration
  def self.up
    drop_table :reasons
  end

  def self.down
    create_table :reasons do |t|
      t.column :description, :string
    end
  end
end
