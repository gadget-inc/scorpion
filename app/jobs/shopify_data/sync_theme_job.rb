# frozen_string_literal: true
module ShopifyData
  class SyncThemeJob < Que::Job
    self.exclusive_execution_lock = true

    def run(shop_domain:, theme_id:, type:)
      Rails.logger.info("Sync theme webhook")
      shopify_shop = ShopifyShop.kept.find_by(domain: shop_domain)
      if type == "theme/delete"
      else
        ShopifyData::ThemeAssetSync.new(shopify_shop).run(theme_id)
      end
    end
  end
end
