# frozen_string_literal: true
module Activity
  # Listens for changes to all the things that might change the feed to enqueue the job to produce the feed
  class FeedListener
    def enqueue_produce_job(shopify_shop_id)
      Infrastructure::UnitOfWork.on_success(idempotency_key: "feed-rebuild-#{shopify_shop_id}") do
        shop = ShopifyShop.kept.find(shopify_shop_id)
        Activity::ProduceFeedJob.enqueue(property_id: shop.property_id)
      end
    end

    def on_shopify_shop_changed(event)
      enqueue_produce_job(event[:shopify_shop_id])
    end

    def on_shopify_theme_changed(event)
      enqueue_produce_job(event[:shopify_shop_id])
    end

    def on_shopify_events_changed(event)
      enqueue_produce_job(event[:shopify_shop_id])
    end
  end
end
