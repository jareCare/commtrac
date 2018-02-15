class User < ActiveRecord::Base

  belongs_to :company
  has_one :picture, 
    :as => :subject
  has_many :payments

  validates_presence_of :email, 
    :password,
    :first_name,
    :last_name,
    :company
  validates_uniqueness_of :email
  validates_confirmation_of :password

  before_save :encrypt_password

  class << self

    def authenticate(email, password)
      find_by_email_and_password email, password.to_sha1
    end

    def admins
      find_all_by_admin true
    end

  end

  def name
    "#{first_name} #{last_name}"
  end

  def remember_me!
    update_attribute :token, "#{email}-#{Time.now}".to_sha1
  end

 protected 

  def encrypt_password
    unless password_confirmation.blank?
      self.password = password.to_sha1
    end
  end

end
