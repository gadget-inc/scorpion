# frozen_string_literal: true
module ShopifyData
  class AppUninstalledJob < Que::Job
    def run(shop_domain:, webhook:)
      Rails.logger.info("App uninstall webhook", webhook: webhook, domain: shop_domain)
      ShopifyShop.kept.find_by!(myshopify_domain: shop_domain)
    end
  end
end
