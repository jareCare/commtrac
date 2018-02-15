class Picture < ActiveRecord::Base

  has_attachment :storage => :file_system
  belongs_to :subject, 
    :polymorphic => true

end
