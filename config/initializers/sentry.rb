# frozen_string_literal: true

Raven.configure do |config|
  if Rails.env.production?
    config.dsn = ENV["BACKEND_SENTRY_DSN"]
  end
  config.release = Fixings::AppRelease.current
  config.rails_activesupport_breadcrumbs = true
end
