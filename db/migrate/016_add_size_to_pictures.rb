class AddSizeToPictures < ActiveRecord::Migration
  def self.up
    add_column :pictures, :size, :integer
  end

  def self.down
    remove_column :pictures, :size
  end
end
