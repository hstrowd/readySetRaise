class CreateTeams < ActiveRecord::Migration
  def change
    create_table :teams do |t|
      t.string :name
      t.float :pledge_target
      t.belongs_to :event, null: false

      t.timestamps
    end

    add_index :teams, :event_id

    create_table :team_members, id: false do |t|
      t.belongs_to :team, null: false
      t.belongs_to :user, null: false
    end
  end
end
