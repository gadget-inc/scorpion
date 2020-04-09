# frozen_string_literal: true
FactoryBot.define do
  factory :shopify_data_app_store_app, class: "ShopifyData::AppStoreApp" do
    title { "MyString" }
    app_store_url { "MyString" }
    app_store_developer_url { "MyString" }
    developer_name { "MyString" }
    developer_url { "MyString" }
    faq_url { "MyString" }
    category { "MyString" }
    image_url { "MyString" }
  end
end
