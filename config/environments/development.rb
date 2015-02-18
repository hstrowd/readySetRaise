Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Uncomment the following three lines to test the asset pipeline.
  # config.assets.digest = true
  # config.assets.precompile += %w( *.png *.gif *.jpg *.jpeg *.ttf *.eot *.svg *.woff )
  # config.assets.debug = false

  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true

  # Required for devise gem.
  config.action_mailer.default_url_options = { host: 'localhost', port: 5000 }

  # The base URL used for any assets included in emails.
  config.action_mailer.asset_host = "http://localhost:5000"

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true
end

ActionMailer::Base.smtp_settings = {
# Development Mailgun Account
#  :port           => 587,
#  :address        => 'smtp.mailgun.org',
#  :user_name      => 'postmaster@dev.teamraising.org',
#  :password       => '035bac1bc8818c9d0fdb21a16158291c',

# Local Mailcatcher Server
  :port           => 1025,
  :address        => 'localhost',

  :domain         => 'dev.teamraising.org',
  :authentication => :plain,
}
ActionMailer::Base.delivery_method = :smtp
