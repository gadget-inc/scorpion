# frozen_string_literal: true

require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_mailbox/engine"
require "action_text/engine"
require "action_view/railtie"
require "action_cable/engine"
require "sprockets/railtie"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Scorpion
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    config.autoload_paths << Rails.root.join("app", "services")
    config.autoload_paths << Rails.root.join("app", "graphql")
    config.autoload_paths << Rails.root.join("app", "warehouse")
    config.autoload_paths << Rails.root.join("app", "lib")
    config.autoload_paths << Rails.root.join("test", "lib")

    config.generators do |g|
      g.factory_bot suffix: "factory"
    end

    config.active_record.index_nested_attribute_errors = true

    # Needed for views and postgres extensions
    config.active_record.schema_format = :sql

    # We use ejson instead of the master key
    config.require_master_key = false

    config.x.domains.app = "should set in the environments"
    config.x.domains.admin = "should be set in the environments"
    config.x.domains.assets = "should be set in the environments"

    config.redis = config_for(:redis)
    config.admin = config_for(:admin)
    config.shopify = config_for(:shopify)
    config.crawler = config_for(:crawler)
    config.google = config_for(:google)
    config.kubernetes = config_for(:kubernetes)
    config.dev_infrastructure = config_for(:dev_infrastructure)

    config.log_tags ||= {}
    config.log_tags[:user_id] = ->(request) { request.session[:current_user_id] }
    config.log_tags[:account_id] = ->(request) { request.session[:current_account_id] }

    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins "*"
        resource "*", headers: :any, methods: [:get], if: proc { |env|
               env["HTTP_HOST"] == Rails.configuration.x.domains.assets
             }
      end
    end
  end
end
