class Organization < ActiveRecord::Base

  validates :name, :description, :homepage_url, :is_verified, :presence => true
  validates :url_key, :presence => true #, :unique => true

  # TODO: Add fields for primary color, secondary color, logo, key
end
