class CreatePledges < ActiveRecord::Migration
  def change
    create_table :pledges do |t|
      # TODO: Fix these.
      t.reference :donor
      t.reference :team
      t.float :amount

      t.timestamps
    end
  end
end
