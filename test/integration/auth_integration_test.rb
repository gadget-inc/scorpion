# frozen_string_literal: true

require "test_helper"

class AuthIntegrationTest < ActionDispatch::IntegrationTest
  setup do
    host! Rails.configuration.x.domains.app
  end

  test "can visit the shopify login page" do
    get "/shopify/login"
    assert_response :success
  end

  test "can get redirected to the Shopify oauth experience" do
    post "/shopify/login", params: { shop: "harry-test-charlie.myshopify.com" }
    assert_response :success # shopify_app does some hullaballoo with cookie storage requests that happens client side, so this isn't actually a redirect but a rendered page that redirects clientside.
  end
end
