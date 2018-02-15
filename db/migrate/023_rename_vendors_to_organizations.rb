class RenameVendorsToOrganizations < ActiveRecord::Migration
  def self.up
    rename_table :vendors, :organizations
    rename_column :accounts, :vendor_id, :organization_id
    add_column :organizations, :organization_type, :string

    organizations = select_all 'select * from organizations'
    organizations.each do |each|
      if each['broker'] == '1'
        organization_type = 'Broker'
      else
        organization_type = 'Vendor'
      end
      update "update organizations
                 set organization_type = '#{organization_type}'
               where id = #{each['id']}"
    end

    remove_column :organizations, :broker
  end

  def self.down
    rename_table :organizations, :vendors
    rename_column :accounts, :organization_id, :vendor_id
    add_column :vendors, :broker, :boolean, :default => false

    vendors = select_all 'select * from vendors'
    vendors.each do |each|
      if each['organization_type'] == 'Broker'
        broker = '1'
      else
        broker = '0'
      end
      update "update vendors
                 set broker = '#{broker}'
               where id = #{each['id']}"
    end

    remove_column :vendors, :organization_type
  end
end
