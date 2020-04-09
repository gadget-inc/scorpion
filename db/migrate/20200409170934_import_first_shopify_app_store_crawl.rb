# frozen_string_literal: true

class ImportFirstShopifyAppStoreCrawl < ActiveRecord::Migration[6.0]
  def up
    ShopifyData::AppStoreScrapeImporter.new(Rails.root.join("db", "shopify-app-store-crawl.csv")).import
  end

  def down
  end
end
