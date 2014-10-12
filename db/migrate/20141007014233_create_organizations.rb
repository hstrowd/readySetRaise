class CreateOrganizations < ActiveRecord::Migration
  def change
    create_table :organizations do |t|
      t.string :name, null: false
      t.string :url_key, null: false, unique: true
      t.text :description, null: false
      t.string :homepage_url, null: false
      t.boolean :is_verified, null: false, default: false
      t.string :donation_url

      t.timestamps
    end
  end
end
