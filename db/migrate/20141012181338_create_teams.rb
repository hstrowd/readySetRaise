class CreateTeams < ActiveRecord::Migration
  def change
    create_table :teams do |t|
      t.string :name
      t.float :pledge_target
      # TODO: add many-to-many to users

      t.timestamps
    end
  end
end
