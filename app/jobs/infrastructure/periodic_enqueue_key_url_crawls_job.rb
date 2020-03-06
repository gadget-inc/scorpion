# frozen_string_literal: true

class Infrastructure::PeriodicEnqueueKeyUrlCrawlsJob < Que::Job
  self.exclusive_execution_lock = true

  def run
    Property.for_purposeful_crawls.find_each do |property|
      Crawl::KeyUrlsCrawlJob.enqueue(property_id: property.id, reason: "scheduled")
    end
  end

  def log_level(_elapsed)
    :info
  end
end
