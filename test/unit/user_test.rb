require File.dirname(__FILE__) + '/../test_helper'

class UserTest < Test::Unit::TestCase

  fixtures :users, :companies

  def test_should_be_associated_with_a_company
    user = User.new

    assert user.respond_to?(:company)

    assert_raise(ActiveRecord::AssociationTypeMismatch) { user.company = Account.new }
  end

  def test_should_find_the_user_with_the_given_email_and_encrypted_password_when_sent_authenticate
    assert_equal users(:user_one),
    User.authenticate(users(:user_one).email, 'user one')

    assert_nil User.authenticate('email', 'password')
  end

  def test_should_be_considered_invalid_without_an_email_and_password_when_sent_valid?
    user = User.new :first_name => 'first', :last_name => 'last',
    :company => companies(:company_one)
    user.email = 'email'
    assert ! user.valid?
    assert_not_nil user.errors.on(:password)

    user = User.new :first_name => 'first', :last_name => 'last',
    :company => companies(:company_one)
    user.password = 'password'
    assert ! user.valid?
    assert_not_nil user.errors.on(:email)

    user = User.new :first_name => 'first', :last_name => 'last',
    :company => companies(:company_one)
    user.email = 'email'
    user.password = 'password'
    assert user.valid?
  end

  def test_should_validate_the_confirmation_of_its_password_when_sent_save_during_initial_creation
    user = User.new :email => 'email', 
    :password => 'password',
    :password_confirmation => 'different password',
    :first_name => 'first',
    :last_name => 'last',
    :company => companies(:company_one)

    assert ! user.valid?
    assert_not_nil user.errors.on(:password)

    user = User.new :email => 'email', 
    :password => 'password',
    :password_confirmation => 'password',
    :first_name => 'first',
    :last_name => 'last',
    :company => companies(:company_one)

    assert user.valid?
  end

  def test_should_encrypt_its_password_when_sent_save_on_initial_creation
    user = User.new :email => 'asdf@asdf.com',
      :password => 'asdf',
      :password_confirmation => 'asdf',
      :first_name => 'first',
      :last_name => 'last',
      :company => companies(:company_one)

    assert user.save
    assert_equal 'asdf'.to_sha1, user.password
  end

  def test_should_encrypt_its_password_when_sent_save_on_an_update
    user = users :user_one
    user.password = 'password'
    user.password_confirmation = 'password'

    assert user.save
    user.reload
    assert_equal 'password'.to_sha1, user.password
  end

  def test_should_not_encrypt_its_password_when_theres_no_password_confirmation_when_sent_save
    user = User.new :email => 'asdf@asdf.com',
      :password => 'asdf',
      :first_name => 'first',
      :last_name => 'last',
      :company => companies(:company_one)

    assert user.save
    assert_not_equal user.password.to_sha1, user.password
  end

  def test_should_be_considered_invalid_if_a_user_with_an_existing_email_already_exists_when_sent_save
    user = User.new :email => 'email', 
    :password => 'password',
    :first_name => 'first',
    :last_name => 'last',
    :company => companies(:company_one)
    assert user.save

    another_user = User.new :email => 'email', 
    :password => 'password',
    :first_name => 'first',
    :last_name => 'last',
    :company => companies(:company_one)
    
    assert ! another_user.save
    assert_not_nil another_user.errors.on(:email)
  end

  def test_should_be_considered_invalid_if_it_doesnt_have_a_first_and_last_name_when_sent_valid?
    user = User.new :email => 'email', :password => 'password',
    :company => companies(:company_one)
    assert ! user.valid?

    user = User.new :email => 'email', :password => 'password',
    :company => companies(:company_one)
    user.first_name = 'first'
    assert ! user.valid?
    assert_not_nil user.errors.on(:last_name)

    user = User.new :email => 'email', :password => 'password',
    :company => companies(:company_one)
    user.last_name = 'last'
    assert ! user.valid?
    assert_not_nil user.errors.on(:first_name)

    user = User.new :email => 'email', :password => 'password',
    :company => companies(:company_one)
    user.first_name = 'first'
    user.last_name = 'last'
    assert user.valid?
  end

  def test_should_returns_its_first_name_and_last_name_when_sent_name
    user = User.new
    user.first_name = 'first'
    user.last_name = 'last'

    assert_equal 'first last', user.name
  end

  def test_should_return_all_admin_users_when_sent_admins
    assert_equal User.find(:all,
                           :conditions => 'admin = true'),
    User.admins
  end

  def test_should_be_considered_invalid_without_a_company_when_sent_valid?
    user = User.new
    user.email = 'email'
    user.password= 'password'
    user.first_name = 'first'
    user.last_name = 'last'

    assert ! user.valid?
    assert_not_nil user.errors.on(:company)
  end

  def test_should_have_many_payments
    user = User.new
    
    assert_respond_to user, :payments

    assert_raise(ActiveRecord::AssociationTypeMismatch) { user.payments << User.new }
  end

  def test_should_update_its_token_when_sent_remember!
    old_token = users(:user_one).token

    assert users(:user_one).remember_me!
    assert_not_equal old_token, users(:user_one).reload.token
  end

end
