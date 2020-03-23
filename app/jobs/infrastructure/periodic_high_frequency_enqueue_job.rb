# frozen_string_literal: true

class Infrastructure::PeriodicHighFrequencyEnqueueJob < Que::Job
  self.exclusive_execution_lock = true

  def run
    Property.for_purposeful_crawls.find_each do |property|
      production_group = Assessment::ProductionGroup.create!(
        property: property,
        account: property.account,
        reason: "scheduled",
        started_at: Time.now.utc,
      )

      Crawl::KeyUrlsCrawlJob.enqueue(property_id: property.id, production_group_id: production_group.id)
    end
  end

  def log_level(_elapsed)
    :info
  end
end
