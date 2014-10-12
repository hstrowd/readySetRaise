class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :title
      t.text :description
      t.datetime :start_time
      t.datetime :end_time
      # TODO: Add reference to fundraiser
      # TODO: Add many-to-many for locations

      t.timestamps
    end
  end
end
