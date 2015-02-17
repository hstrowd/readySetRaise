class ChangeFundraiserDescriptionsToText < ActiveRecord::Migration
  def change
    change_column :fundraisers, :description, :text, null: false
  end
end
