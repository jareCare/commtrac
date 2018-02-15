class Organization < ActiveRecord::Base

  TYPES = %w(Broker Vendor)

  has_many :accounts, :dependent => :destroy

  validates_presence_of :name
  validates_inclusion_of :organization_type, 
    :in => TYPES

  def vendor?
    organization_type == 'Vendor'
  end

  def broker?
    organization_type == 'Broker'
  end

end
