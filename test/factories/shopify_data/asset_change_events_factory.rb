# frozen_string_literal: true
FactoryBot.define do
  factory :shopify_data_asset_change_event, class: "ShopifyData::AssetChangeEvent" do
    association :account
    association :shopify_shop
    association :theme, factory: :shopify_data_theme
    key { "snippets/thing.liquid" }
    action { "create" }
    action_at { "2020-03-02 18:49:35" }
  end
end
