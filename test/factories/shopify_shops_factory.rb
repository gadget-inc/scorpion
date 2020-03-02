# frozen_string_literal: true
FactoryBot.define do
  factory :shopify_shop do
    association :account
    association :property

    domain { ENV["SHOPIFY_SHOP_OAUTH_DOMAIN"] }
    api_token { ENV["SHOPIFY_SHOP_OAUTH_ACCESS_TOKEN"] }

    after(:build) do |shop|
      shop.creator = shop.account.creator
    end
  end
end
