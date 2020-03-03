# frozen_string_literal: true
FactoryBot.define do
  factory :shopify_data_theme, class: "ShopifyData::Theme" do
    association :account
    association :shopify_shop
    theme_id { 1 }
    name { "Whatever" }
    role { "main" }
    theme_store_id { nil }
    shopify_created_at { "2020-03-02 18:33:07" }
    shopify_updated_at { "2020-03-02 18:33:07" }
    asset_change_tracker { {} }
  end
end
