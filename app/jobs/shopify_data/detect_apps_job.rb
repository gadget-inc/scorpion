# frozen_string_literal: true
module ShopifyData
  class DetectAppsJob < Que::Job
    self.exclusive_execution_lock = true

    def run(shopify_shop_id:)
      shop = ShopifyShop.kept.find(shopify_shop_id)
      ShopifyData::AppDetector.new(shop).detect
    end
  end
end
