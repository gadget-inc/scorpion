# frozen_string_literal: true
FactoryBot.define do
  factory :shopify_shop do
    transient do
      property_factory { :property }
    end

    domain { "coolsite.store" }
    myshopify_domain { ENV["SHOPIFY_SHOP_OAUTH_DOMAIN"] }
    api_token { ENV["SHOPIFY_SHOP_OAUTH_ACCESS_TOKEN"] }

    after(:build) do |shop, evaluator|
      shop.property ||= build(evaluator.property_factory, shopify_shop: shop)
      shop.account = shop.property.account
      shop.creator = shop.account.creator
    end

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
