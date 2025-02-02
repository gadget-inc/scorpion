# frozen_string_literal: true

# Test-like environment for integration tests that tries to mimic production but
# is set up to run a webserver for Cypress.

Rails.application.configure do
  # Reload in integration tests so its easier to rerun the tests
  config.cache_classes = false
  config.eager_load = false

  # Configure public file server for tests with Cache-Control for performance.
  config.public_file_server.enabled = true
  config.public_file_server.headers = {
    "Cache-Control" => "public, max-age=#{1.hour.to_i}",
  }

  # Show full error reports and disable caching.
  config.consider_all_requests_local = true
  config.action_controller.perform_caching = true

  config.cache_store = :redis_cache_store, { driver: :hiredis, url: config.redis[:url] }
  config.session_store :cache_store, key: "scorpion_integration_test_sessions"

  # Raise exceptions instead of rendering exception templates.
  config.action_dispatch.show_exceptions = false

  # Store uploaded files on the local file system in a temporary directory.
  config.active_storage.service = :test

  config.action_mailer.perform_caching = true

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test
  config.action_mailer.default_url_options = { host: "test-emails.ggt.dev" }

  # Print deprecation notices to the stderr.
  config.active_support.deprecation = :stderr

  # Raises error for missing translations.
  config.action_view.raise_on_missing_translations = true

  config.x.domains.app = "app.ggt.dev"
  config.x.domains.admin = "admin.ggt.dev"
  config.x.domains.assets = "assets.ggt.dev"
  config.x.domains.webhooks = ENV.fetch("WEBHOOK_HOST", config.x.domains.app)
  config.action_controller.asset_host = config.x.domains.assets
  config.hosts << ".ggt.dev"
end
