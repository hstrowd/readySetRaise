class CreateOrganizations < ActiveRecord::Migration
  def change
    create_table :organizations do |t|
      t.string :name, null: false
      t.string :url_key, null: false
      t.text :description, null: false
      t.string :homepage_url, null: false
      t.boolean :is_verified, null: false, default: false
      t.string :donation_url

      t.timestamps
    end

    create_table :organization_members, id: false do |t|
      t.belongs_to :organization, null: false
      t.belongs_to :user, null: false
    end

    add_index :organizations, :url_key, unique: true
  end
end
