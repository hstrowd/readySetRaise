class MigrateDonationUrlToEvents < ActiveRecord::Migration
  def change
    add_column :events, :donation_url, :string

    Organization.all.each do |org|
      org.events.each do |event|
        event.update_attributes!(donation_url: org.donation_url)
      end
    end
  end
end
