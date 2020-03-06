# frozen_string_literal: true

class Infrastructure::PeriodicEnqueueInteractionTestsJob < Que::Job
  self.exclusive_execution_lock = true

  def run
    Property.for_purposeful_crawls.find_each do |property|
      Crawl::InteractionRunnerJob.enqueue(property_id: property.id, reason: "scheduled", interaction_id: "shopify-browse-add")
    end
  end

  def log_level(_elapsed)
    :info
  end
end
