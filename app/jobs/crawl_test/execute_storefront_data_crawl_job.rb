# frozen_string_literal: true

module CrawlTest
  class ExecuteStorefrontDataCrawlJob < Que::Job
    include SemanticLogger::Loggable

    self.maximum_retry_count = 0
    self.exclusive_execution_lock = true
    self.queue = "crawl_tests"
    self.priority = 100

    def run(property_id:)
      property = Property.for_ambient_crawls.find(property_id)
      Assessor.new(property).run_storefront_data_crawl
    end
  end
end
