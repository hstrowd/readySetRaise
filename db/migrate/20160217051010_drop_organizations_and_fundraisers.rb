class DropOrganizationsAndFundraisers < ActiveRecord::Migration
  def change
    drop_table :organization_memberships
    drop_table :organizations
    drop_table :fundraisers
    remove_column :events, :fundraiser_id
  end
end
