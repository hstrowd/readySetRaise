class ChangeOrgDonationUrlToNotNull < ActiveRecord::Migration
  def change
    raise 'Organizations exist with null as their donation URL. Please correct this and rerun the migration.' if Organization.find_by_donation_url nil

    change_column :organizations, :donation_url, :string, null: false
  end
end
