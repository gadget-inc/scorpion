# frozen_string_literal: true

class Infrastructure::PeriodicShopifySyncEnqueueJob < Que::Job
  self.exclusive_execution_lock = true

  def run
    ShopifyShop.kept.find_each do |shopify_shop|
      ShopifyData::AllSyncJob.enqueue(shopify_shop_id: shopify_shop.id)
    end
  end

  def log_level(_elapsed)
    :info
  end
end
