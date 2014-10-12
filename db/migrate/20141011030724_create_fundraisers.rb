class CreateFundraisers < ActiveRecord::Migration
  def change
    create_table :fundraisers do |t|
      t.string :title, null: false
      t.string :description, null: false
      t.datetime :pledge_start_time, null: false
      t.datetime :pledge_end_time, null: false
      # TODO: Add reference to an organization

      t.timestamps
    end
  end
end
