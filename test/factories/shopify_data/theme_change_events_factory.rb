# frozen_string_literal: true
FactoryBot.define do
  factory :shopify_data_theme_change_event, class: "ShopifyData::ThemeChangeEvent" do
    association :shopify_shop
    association :theme, factory: :shopify_data_theme
    record_attribute { "role" }
    new_value { "main" }
    old_value { "other" }

    after(:build) do |event|
      event.account ||= event.shopify_shop.account
    end
  end
end
