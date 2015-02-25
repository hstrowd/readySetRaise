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
    teamDescriptor = TeamDescriptor.create!({
        singular: 'Team',
        plural: 'Teams'
      })

    Event.all.each do |event|
      event.team_descriptor = teamDescriptor
      event.save!
    end

    change_column :events, :team_descriptor_id, :integer, null: false

    add_index :events, :team_descriptor_id
  end

  def down
    remove_index :events, :team_descriptor_id

    remove_column :events, :team_descriptor_id, :integer

    drop_table :team_descriptors
  end
end
