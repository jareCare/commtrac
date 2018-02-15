require File.dirname(__FILE__) + '/../test_helper'

class OrganizationTest < Test::Unit::TestCase

  fixtures :organizations, :accounts

  def test_should_have_many_accounts
    organization = Organization.new

    assert organization.respond_to?(:accounts)

    assert_raise(ActiveRecord::AssociationTypeMismatch) { organization.accounts << User.new }
  end

  def test_should_be_considered_invalid_if_it_does_not_have_a_name_when_sent_valid?
    organization = Organization.new
    assert ! organization.valid?
    assert_not_nil organization.errors.on(:name)

    organization = Organization.new 
    organization.name = 'name'
    organization.organization_type = 'Broker'
    assert organization.valid?
  end

  def test_should_delete_its_accounts_when_sent_destroy
    assert ! organizations(:vendor_one).accounts.empty?

    assert organizations(:vendor_one).destroy

    assert Account.find(:all,
                        :conditions => { :organization_id => organizations(:vendor_one).id }).empty?
  end

  def test_should_say_if_its_a_vendor_when_sent_vendor?
    assert organizations(:vendor_one).vendor?

    assert ! organizations(:broker_one).vendor?
  end

  def test_should_say_if_its_a_broker_when_sent_broker?
    assert organizations(:broker_one).broker?

    assert ! organizations(:vendor_one).broker?
  end

  def test_should_be_considered_invalid_if_its_type_isnt_a_legal_type_when_sent_valid?
    %w(Broker Vendor).each do |each|
      organization = Organization.new :organization_type => each,
        :name => 'name'
      assert organization.valid?
    end

    organization = Organization.new :organization_type => 'organization_type',
      :name => 'name'
    assert ! organization.valid?
  end

end
