class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :title
      t.text :description
      t.datetime :start_time
      t.datetime :end_time
      t.belongs_to :fundraiser, null: false
      t.belongs_to :creator, null: false

      t.timestamps
    end

    add_index :events, :fundraiser_id
  end
end
