# frozen_string_literal: true

class Assessment::AssessProductDataJob < Que::Job
  self.maximum_retry_count = 0
  self.exclusive_execution_lock = true
  self.queue = "crawls"

  def run(shopify_shop_id:, production_group_id:)
    shop = ShopifyShop.kept.find(shopify_shop_id)
    production_group = Assessment::ProductionGroup.find(production_group_id)
    Assessment::ShopifyProductDataAssessor.new(shop, production_group).assess_all
  end
end
