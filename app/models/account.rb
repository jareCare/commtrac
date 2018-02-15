class Account < ActiveRecord::Base

  belongs_to :company
  belongs_to :organization
  has_many :payments, :dependent => :destroy

  validates_presence_of :number, 
    :company, 
    :organization
  validates_uniqueness_of :company_id, 
    :scope => :organization_id,
    :message => 'association already exists'

end
