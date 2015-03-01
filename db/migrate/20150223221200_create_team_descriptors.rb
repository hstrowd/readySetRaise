class CreateTeamDescriptors < ActiveRecord::Migration
  def up
    create_table :team_descriptors do |t|
      t.string :singular, null: false
      t.string :plural, null: false

      t.timestamps
    end
    add_index :team_descriptors, :singular, unique: true

    add_column :events, :team_descriptor_id, :integer

    # Add a default entry and populate all existing records with this.
    # Operate directly on the DB to ensure future model changes don't break this logic.
    TeamDescriptor.connection.execute("""
INSERT INTO team_descriptors
    ( id
    , singular
    , plural
    )
  VALUES
    ( 1
    , 'Team'
    , 'Teams'
    );
""")

    Event.connection.execute('UPDATE events SET team_descriptor_id = 1 WHERE team_descriptor_id IS NULL;')

    change_column :events, :team_descriptor_id, :integer, null: false

    add_index :events, :team_descriptor_id
  end

  def down
    remove_index :events, :team_descriptor_id

    remove_column :events, :team_descriptor_id, :integer

    drop_table :team_descriptors
  end
end
