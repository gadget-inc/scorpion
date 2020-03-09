# frozen_string_literal: true

class Assessment::AssessProductDataJob < Que::Job
  self.maximum_retry_count = 0
  self.exclusive_execution_lock = true
  self.queue = "crawls"

  def run(shopify_shop_id:, reason:)
    shop = ShopifyShop.kept.find(shopify_shop_id)
    Assessment::ShopifyProductDataAssessor.new(shop, reason).assess_all
  end
end
