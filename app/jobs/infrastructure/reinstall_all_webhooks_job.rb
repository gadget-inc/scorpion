# frozen_string_literal: true

# Not run regularly, used when the script tag url changes and we need to sync it everywhere
class Infrastructure::ReinstallAllWebhooksJob < Que::Job
  def run
    ShopifyShop.kept.find_each do |shopify_shop|
      Infrastructure::ReinstallWebhooksJob.enqueue(shopify_shop_id: shopify_shop.id)
    end
  end
end
