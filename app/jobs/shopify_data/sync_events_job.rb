# frozen_string_literal: true
module ShopifyData
  class SyncEventsJob < Que::Job
    self.exclusive_execution_lock = true

    def run(shop_domain:)
      Rails.logger.info("Sync events webhook")
      shop = ShopifyShop.kept.find_by(domain: shop_domain)
      ShopifyData::EventsSync.new(shop).run
    end
  end
end
