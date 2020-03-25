# frozen_string_literal: true
FactoryBot.define do
  factory :shopify_data_detected_app_change_event, class: "ShopifyData::DetectedAppChangeEvent" do
    association :detected_app, factory: :shopify_data_detected_app
    association :shopify_shop

    action { "detected" }
    action_at { "2020-03-16 18:21:51" }

    after(:build) do |event|
      event.account ||= event.shopify_shop.account
    end
  end
end
