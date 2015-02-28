class AddUrlKeyToEvents < ActiveRecord::Migration
  def change
    add_column :events, :url_key, :string
  end
end
