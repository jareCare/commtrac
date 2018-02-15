class CreatePictures < ActiveRecord::Migration
  def self.up
    create_table :pictures do |t|
      t.column :filename, :string
      t.column :content_type, :string
      t.column :created_on, :datetime
      t.column :subject_id, :integer
      t.column :subject_type, :string
    end
  end

  def self.down
    drop_table :pictures
  end
end
