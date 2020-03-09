# frozen_string_literal: true

class Infrastructure::PeriodicMediumFrequencyEnqueueJob < Que::Job
  self.exclusive_execution_lock = true

  def run
    Property.for_purposeful_crawls.includes(:shopify_shop).find_each do |property|
      Crawl::InteractionRunnerJob.enqueue(property_id: property.id, reason: "scheduled", interaction_id: "shopify-browse-add")

      if property.shopify_shop.present?
        Assessment::AssessProductDataJob.enqueue(shopify_shop_id: property.shopify_shop.id, reason: "scheduled")
      end
    end
  end

  def log_level(_elapsed)
    :info
  end
end
