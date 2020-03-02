# frozen_string_literal: true

# Not run regularly, used when the script tag url changes and we need to sync it on a given shop
class Infrastructure::ReinstallWebhooksJob < Que::Job
  def run(shopify_shop_id:)
    shop = ShopifyShop.kept.find(shopify_shop_id)
    shop.with_shopify_session do
      manager = ShopifyApp::WebhooksManager.new(ShopifyApp.configuration.webhooks)

      ShopifyAPI::Webhook.all.to_a.each do |webhook|
        ShopifyAPI::Webhook.delete(webhook.id)
      end

      manager.create_webhooks
    end
  end
end
