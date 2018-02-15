require File.dirname(__FILE__) + '/../test_helper'

class AccountTest < Test::Unit::TestCase

  fixtures :companies, 
    :organizations, 
    :accounts,
    :payments,
    :users

  def test_should_be_associated_with_a_company
    account = Account.new

    assert account.respond_to?(:company)

    assert_raise(ActiveRecord::AssociationTypeMismatch) { account.company = User.new }
  end

  def test_should_be_associated_with_an_organization
    account = Account.new

    assert account.respond_to?(:vendor)

    assert_raise(ActiveRecord::AssociationTypeMismatch) { account.organization = User.new }
  end

  def test_should_be_considered_invalid_without_a_number_when_sent_valid?
    account = Account.new

    assert ! account.valid?
    assert_not_nil account.errors.on(:number)
  end

  def test_should_be_considered_invalid_without_a_company_when_sent_valid?
    account = Account.new

    assert ! account.valid?
    assert_not_nil account.errors.on(:company)
  end

  def test_should_be_considered_invalid_without_a_organization_when_sent_valid?
    account = Account.new

    assert ! account.valid?
    assert_not_nil account.errors.on(:organization)
  end

  def test_should_have_many_payments
    account = Account.new

    assert account.respond_to?(:payments)

    assert_raise(ActiveRecord::AssociationTypeMismatch) { account.payments << User.new }
  end

  def test_should_be_considered_invalid_if_an_account_already_exists_between_the_given_company_and_organization
    company = Company.new
    company.name = 'name'
    company.best_commission_rate = 1.2
    company.soft_commission_rate = 1.2
    company.credit_rate = 1.5
    assert company.save

    organization = Organization.new
    organization.name = 'name'

    one = Account.new :company => company,
    :organization => organization,
    :number => '1'
    assert one.save

    two = Account.new :company => company,
    :organization => organization,
    :number => '2'
    assert ! two.valid?
  end

  def test_should_delete_its_payments_when_sent_destroy
    assert ! accounts(:company_one_vendor_one).payments.empty?
    assert accounts(:company_one_vendor_one).destroy

    assert Payment.find(:all,
                        :conditions => ['account_id = ?', 
                                        accounts(:company_one_vendor_one).id]).empty?
  end

  def test_should_be_associated_with_an_organization
    account = Account.new

    assert account.respond_to?(:organization)

    assert_raise(ActiveRecord::AssociationTypeMismatch) { account.organization = User.new }
  end

end

