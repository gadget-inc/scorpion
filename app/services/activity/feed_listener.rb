# frozen_string_literal: true
module Activity
  # Listens for changes to all the things that might change the feed to enqueue the job to produce the feed
  class FeedListener
    def enqueue_produce_job(property_id)
      Infrastructure::UnitOfWork.on_success(idempotency_key: "feed-rebuild-#{property_id}") do
        property = Property.find(property_id)
        if property.discarded_at.nil? && !property.ambient
          Activity::ProduceFeedJob.enqueue(property_id: property.id)
        end
      end
    end

    def on_shopify_shop_changed(event)
      enqueue_produce_job(event[:property_id])
    end

    def on_shopify_theme_changed(event)
      enqueue_produce_job(event[:property_id])
    end

    def on_shopify_events_changed(event)
      enqueue_produce_job(event[:property_id])
    end

    def on_shopify_apps_changed(event)
      enqueue_produce_job(event[:property_id])
    end

    def on_assessments_changed(event)
      enqueue_produce_job(event[:property_id])
    end
  end
end
