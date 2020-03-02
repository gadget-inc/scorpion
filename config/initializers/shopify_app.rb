# frozen_string_literal: true

ShopifyApp.configure do |config|
  config.application_name = "Scorpion"
  config.root_url = "/shopify"
  config.api_key = Rails.configuration.shopify.api_key
  config.secret = Rails.configuration.shopify.api_secret_key
  config.old_secret = ""
  config.per_user_tokens = true
  config.scope = "read_products,read_content,read_themes,read_locations,write_script_tags,read_shipping"

  config.embedded_app = true
  config.after_authenticate_job = false
  config.api_version = "2020-01"
  config.session_repository = "Infrastructure::ShopifyUserSessionRepository"
end

ShopifyAPI::Base.api_version = "2020-01"
ShopifyAPI::GraphQL.initialize_clients
