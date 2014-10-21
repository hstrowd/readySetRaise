class CreateOrganizations < ActiveRecord::Migration
  def change
    create_table :organizations do |t|
      t.string :name, null: false
      t.string :url_key, null: false
      t.text :description, null: false
      t.string :homepage_url, null: false
      t.boolean :is_verified, null: false, default: false
      t.string :donation_url
      t.belongs_to :creator, null: false

      t.timestamps
    end

    create_table :organization_memberships, id: false do |t|
      t.belongs_to :organization, null: false
      t.belongs_to :member, null: false
    end

    add_index :organizations, :url_key, unique: true
    add_index :organizations, :creator_id
  end
end
