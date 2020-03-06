# frozen_string_literal: true
module ShopifyData
  # Enqueues all jobs necessary to get a shop up to date. Useful for signup and for periodic syncs to find anything we didn't get in webhooks
  class AllSync
    include ShopifyApiRetries
    attr_reader :shop

    def initialize(shop)
      @shop = shop
    end

    def run
      ShopifyData::SyncEventsJob.enqueue(shop_domain: @shop.myshopify_domain)
      ShopifyData::SyncShopJob.enqueue(shop_domain: @shop.myshopify_domain)

      @shop.with_shopify_session do
        themes = with_retries { ShopifyAPI::Theme.find(:all) }
        themes.each do |theme|
          ShopifyData::SyncThemeJob.enqueue(shop_domain: @shop.myshopify_domain, remote_theme_id: theme.id, type: "theme/update")
        end
      end
      nil
    end
  end
end
