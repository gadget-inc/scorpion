# frozen_string_literal: true
FactoryBot.define do
  factory :shopify_data_event, class: "ShopifyData::Event" do
    association :account
    association :shopify_shop
    event_id { 1 }
    subject_id { 1 }
    verb { "MyString" }
    path { "MyString" }
    author { "MyString" }
    body { "MyString" }
    description { "MyString" }
    arguments { "MyString" }
    shopify_created_at { "2020-03-02 14:43:20" }
  end
end
