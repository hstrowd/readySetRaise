class AddMonthlyFlagToPledge < ActiveRecord::Migration
  def change
    add_column :pledges, :monthly, :boolean, null: false, default: false
  end
end
