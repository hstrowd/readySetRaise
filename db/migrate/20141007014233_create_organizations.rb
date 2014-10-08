class CreateOrganizations < ActiveRecord::Migration
  def change
    create_table :organizations do |t|
      t.string :name
      t.text :description
      t.string :homepage_url
      t.boolean :is_verified
      t.string :donation_url

      t.timestamps
    end
  end
end
