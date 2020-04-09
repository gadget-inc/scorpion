# frozen_string_literal: true
require "test_helper"

class ShopifyData::AppStoreScrapeImporterTest < ActiveSupport::TestCase
  setup do
    @importer = ShopifyData::AppStoreScrapeImporter.new(Rails.root.join("db", "shopify-app-store-crawl.csv"), limit: 100)
  end

  test "it can import the scrape" do
    assert_difference "ShopifyData::AppStoreApp.count", 100 do
      @importer.import
    end

    assert_difference "ShopifyData::AppStoreApp.count", 0 do
      @importer.import
    end
  end
end
