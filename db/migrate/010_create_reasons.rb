class CreateReasons < ActiveRecord::Migration
  def self.up
    create_table :reasons do |t|
      t.column :description, :string
    end
  end

  def self.down
    drop_table :reasons
  end
end
