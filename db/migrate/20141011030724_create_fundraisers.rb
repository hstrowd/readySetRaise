class CreateFundraisers < ActiveRecord::Migration
  def change
    create_table :fundraisers do |t|
      t.string :title, null: false
      t.string :description
      t.datetime :pledge_start_time, null: false
      t.datetime :pledge_end_time, null: false
      t.belongs_to :organization, null: false
      t.belongs_to :creator, null: false

      t.timestamps
    end

    add_index :fundraisers, :organization_id
  end
end
