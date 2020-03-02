# frozen_string_literal: true

OmniAuth.config.logger = SemanticLogger[OmniAuth]

HOST_CONSTRAINT_SETUP = lambda do |env|
  req = Rack::Request.new(env)
  if req.host != Rails.configuration.x.domains.app
    raise ActionController::RoutingError, "Not Found"
  end
end

SHOPIFY_SCOPE = "read_products,read_content,read_themes,read_locations,write_script_tags,read_shipping"

module OmniAuth::Strategies
  class ShopifyOffline < Shopify
    def name
      :shopify_offline
    end
  end
end

Rails.application.config.middleware.use OmniAuth::Builder do
  # frozen_string_literal: true

  shopify_strategy_setup = lambda { |env|
    strategy = env["omniauth.strategy"]

    shopify_auth_params = strategy.session["shopify.omniauth_params"]&.with_indifferent_access
    shop = if shopify_auth_params.present?
        "https://#{shopify_auth_params[:shop]}"
      else
        ""
      end

    strategy.options[:client_options][:site] = shop
    strategy.options[:old_client_secret] = ShopifyApp.configuration.old_secret
  }

  # We use two omniauth providers, one for user authentication, and one for shop wide authentication to get an offline access token
  provider :shopify_offline,
    ShopifyApp.configuration.api_key,
    ShopifyApp.configuration.secret,
    name: "shopify_offline",
    scope: ShopifyApp.configuration.scope,
    per_user_permissions: false,
    setup: shopify_strategy_setup,
    callback_path: "/shopify/auth/shopify_offline/callback"

  provider :shopify,
    ShopifyApp.configuration.api_key,
    ShopifyApp.configuration.secret,
    scope: ShopifyApp.configuration.scope,
    per_user_permissions: true,
    setup: shopify_strategy_setup,
    callback_path: "/shopify/auth/shopify/callback"
end
