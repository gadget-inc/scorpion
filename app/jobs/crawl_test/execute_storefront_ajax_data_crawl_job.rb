# frozen_string_literal: true

module CrawlTest
  class ExecuteStorefrontAjaxDataCrawlJob < Que::Job
    include SemanticLogger::Loggable

    self.maximum_retry_count = 0
    self.exclusive_execution_lock = true
    self.queue = "crawl_tests"
    self.priority = 100

    def run(property_id:, production_group_id:)
      property = Property.for_ambient_crawls.find(property_id)
      production_group = Assessment::ProductionGroup.find(production_group_id)
      Assessor.new(property, production_group).run_storefront_data_crawl
    end
  end
end
