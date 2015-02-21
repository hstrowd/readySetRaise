class AddAnonymousFlagToPledge < ActiveRecord::Migration
  def change
    add_column :pledges, :anonymous, :boolean, null: false, default: false
  end
end
