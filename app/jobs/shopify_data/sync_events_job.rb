# frozen_string_literal: true
module ShopifyData
  class SyncEventsJob < Que::Job
    self.exclusive_execution_lock = true

    def run(shop_domain:)
      shop = ShopifyShop.kept.find_by(domain: shop_domain)
      ShopifyData::EventsSync.new(shop).run
    end
  end
end
