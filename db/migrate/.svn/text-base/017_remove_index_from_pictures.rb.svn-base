class RemoveIndexFromPictures < ActiveRecord::Migration
  def self.up
    remove_index :pictures, :name => 'index_pictures_on_subject_id_and_subject_type'
  end

  def self.down
    add_index :pictures, [:subject_id, :subject_type], :unique => true
  end
end
