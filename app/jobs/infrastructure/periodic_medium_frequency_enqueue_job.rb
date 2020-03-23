# frozen_string_literal: true

class Infrastructure::PeriodicMediumFrequencyEnqueueJob < Que::Job
  self.exclusive_execution_lock = true

  def run
    Property.for_purposeful_crawls.includes(:shopify_shop).find_each do |property|
      production_group = Assessment::ProductionGroup.create(
        property: property,
        account: property.account,
        reason: "scheduled",
        started_at: Time.now.utc,
      )

      Crawl::InteractionRunnerJob.enqueue(property_id: property.id, production_group_id: production_group.id, interaction_id: "shopify-browse-add")

      if property.shopify_shop.present?
        Assessment::AssessProductDataJob.enqueue(shopify_shop_id: property.shopify_shop.id, production_group_id: production_group.id)
      end
    end
  end

  def log_level(_elapsed)
    :info
  end
end
