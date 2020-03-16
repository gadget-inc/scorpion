# frozen_string_literal: true
FactoryBot.define do
  factory :shopify_data_detected_app, class: "ShopifyData::DetectedApp" do
    association :account
    association :shopify_shop
    name { "Yotpo" }
    first_seen_at { "2020-03-16 17:53:59" }
    last_seen_at { "2020-03-16 17:53:59" }
    seen_last_time { true }
    reasons { ["Detected third party javascript"] }
  end
end
