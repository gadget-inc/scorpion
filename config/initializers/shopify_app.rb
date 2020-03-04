# frozen_string_literal: true

ShopifyApp.configure do |config|
  config.application_name = "Scorpion"
  config.root_url = "/shopify"
  config.api_key = Rails.configuration.shopify.api_key
  config.secret = Rails.configuration.shopify.api_secret_key
  config.old_secret = ""
  config.per_user_tokens = true
  config.scope = "read_products,read_content,write_themes,read_locations,write_script_tags,read_shipping"

  config.embedded_app = true
  config.after_authenticate_job = false
  config.api_version = "2020-01"
  config.session_repository = "Infrastructure::ShopifyUserSessionRepository"

  config.webhook_jobs_namespace = "shopify_data"
  config.webhooks = [
    { topic: "app/uninstalled", address: "https://#{Rails.configuration.x.domains.webhooks}/shopify/webhooks/app_uninstalled", format: "json" },
    { topic: "shop/update", address: "https://#{Rails.configuration.x.domains.webhooks}/shopify/webhooks/sync_shop", format: "json" },
  ] + [
    "products/create",
    "products/update",
    "products/delete",
    "collections/create",
    "collections/update",
    "collections/delete",
    "shop/update",
  ].map do |topic|
    { topic: topic, address: "https://#{Rails.configuration.x.domains.webhooks}/shopify/webhooks/sync_events", format: "json" }
  end + [
    "themes/create",
    "themes/publish",
    "themes/update",
    "themes/delete",
  ].map do |topic|
    { topic: topic, address: "https://#{Rails.configuration.x.domains.webhooks}/shopify/webhooks/sync_theme", format: "json" }
  end
end

ShopifyAPI::Base.api_version = "2020-01"
ShopifyAPI::GraphQL.initialize_clients
