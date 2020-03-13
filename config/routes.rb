# frozen_string_literal: true

require "que/web"

Rails.application.routes.draw do
  health_check_routes

  constraints host: Rails.configuration.x.domains.admin do
    constraints AdminAuthConstraint.new do
      mount Que::Web, at: "/que"
      mount Flipper::UI.app(Flipper) => "/flipper"
    end

    mount Trestle::Engine => Trestle.config.path
  end

  if Rails.env.integration_test? || Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"

    scope "test_support" do
      post "clean", to: "test_support#clean"
      post "force_login", to: "test_support#force_login"
      post "empty_account", to: "test_support#empty_account"
      post "set_account_flipper_flag", to: "test_support#set_account_flipper_flag"
      get "last_delivered_email", to: "test_support#last_delivered_email"
    end
  end

  constraints ->(request) { request.host == Rails.configuration.x.domains.app || request.host == Rails.configuration.x.domains.webhooks } do
    mount ShopifyApp::Engine, at: "/shopify"
    get "/shopify/auth/shopify_offline/callback", to: "shopify_app/callback#offline_callback"

    scope module: :app do
      mount GraphiQL::Rails::Engine, at: "/graphiql", graphql_path: "graphql", as: "app_graphiql"
      post "/graphql", to: "graphql#execute"

      # Special requests that dont just go into the normal application chrome
      scope "s" do
      end

      # Forward all the other requests to the edit area client side router
      get "*path", to: "client_side_app#index", as: "app_client_side_app"
      root to: "client_side_app#index", as: "app_root"
    end
  end
end
