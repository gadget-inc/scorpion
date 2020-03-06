# frozen_string_literal: true
module ShopifyData
  class SyncShopJob < Que::Job
    self.exclusive_execution_lock = true

    def run(shop_domain:)
      shop = ShopifyShop.kept.find_by!(myshopify_domain: shop_domain)
      ShopifyData::ShopSync.new(shop).run
    end
  end
end
