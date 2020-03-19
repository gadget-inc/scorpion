# frozen_string_literal: true

class CrawlTest::PeriodicExecuteAssessmentsJob < Que::Job
  self.exclusive_execution_lock = true

  def run
    Property.for_ambient_crawls.find_each do |property|
      CrawlTest::ExecuteInteractionCrawlsJob.enqueue(property_id: property.id)
      CrawlTest::ExecuteLighthouseAssessmentsJob.enqueue(property_id: property.id)
      CrawlTest::ExecuteStorefrontDataCrawlJob.enqueue(property_id: property.id)
    end
  end

  def log_level(_elapsed)
    :info
  end
end
