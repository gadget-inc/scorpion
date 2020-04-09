# frozen_string_literal: true
FactoryBot.define do
  factory :shopify_data_app_store_app, class: "ShopifyData::AppStoreApp" do
    title { "Superspeed - Free Speed Boost" }
    app_store_url { "https://apps.shopify.com/superspeed-free-speed-boost" }
    app_store_developer_url { "https://apps.shopify.com/partners/scorpion2" }
    developer_name { "Gadget" }
    developer_url { "https://superspeed.gadget.dev/" }
    faq_url { nil }
    category { "Store design" }
    image_url { "https://apps.shopifycdn.com/listing_images/2ff65525543e6c40c30a54a999e386c7/icon/5605cd688ee441350dd549eab5abcf18.png?height=168&width=168" }
    inferred_domains { ["superspeed.gadget.dev"] }
    confirmed_domains { ["superspeed.gadget.dev"] }
    priority { 1 }
  end
end
