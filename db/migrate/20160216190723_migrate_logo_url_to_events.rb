class MigrateLogoUrlToEvents < ActiveRecord::Migration
  def change
    add_column :events, :logo_url, :string

    Organization.all.each do |org|
      org.events.each do |event|
        event.update_attributes!(logo_url: org.logo_url)
      end
    end
  end
end
