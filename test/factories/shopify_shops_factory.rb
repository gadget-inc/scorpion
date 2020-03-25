# frozen_string_literal: true
FactoryBot.define do

  # Where possible, use this fixture and mock stuff so the tests aren't coupled to remote responses
  factory :shopify_shop do
    transient do
      property_factory { :property }
    end

    domain { "coolsite.store" }
    myshopify_domain { "coolsite.myshopify.com" }
    api_token { "deadbeefdeadbeef" }

    after(:build) do |shop, evaluator|
      shop.property ||= build(evaluator.property_factory, shopify_shop: shop)
      shop.account = shop.property.account
      shop.creator = shop.account.creator
    end

    # When testing against Shopify, use this fixture to be able to rerecord VCR tests easily
    # Run rake dev:env_vars to set the right environment up to record VCR tests against a live shop
    factory :live_test_myshopify_shop do
      domain { ENV["SHOPIFY_SHOP_OAUTH_DOMAIN"] }
      myshopify_domain { ENV["SHOPIFY_SHOP_OAUTH_DOMAIN"] }
      api_token { ENV["SHOPIFY_SHOP_OAUTH_ACCESS_TOKEN"] }

      transient do
        property_factory { :live_test_myshopify_property }
      end
    end
  end
end
