class CreatePledges < ActiveRecord::Migration
  def change
    create_table :pledges do |t|
      t.belongs_to :user  # donor
      t.belongs_to :team
      t.float :amount

      t.timestamps
    end

    add_index :pledges, :user_id
    add_index :pledges, :team_id
  end
end
