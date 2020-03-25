# frozen_string_literal: true
FactoryBot.define do
  factory :shopify_data_shop_change_event, class: "ShopifyData::ShopChangeEvent" do
    association :shopify_shop
    record_attribute { "name" }
    old_value { "Test Shop" }
    new_value { "Cool Shop" }

    after(:build) do |event|
      event.account ||= event.shopify_shop.account
    end
  end
end
