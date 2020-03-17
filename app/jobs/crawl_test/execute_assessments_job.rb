# frozen_string_literal: true

module CrawlTest
  class ExecuteAssessmentsJob < Que::Job
    include SemanticLogger::Loggable

    self.maximum_retry_count = 0
    self.exclusive_execution_lock = true
    self.queue = "crawl_tests"

    def run(property_id:)
      property = Property.for_ambient_crawls.find(property_id)
      Assessor.new(property).run_all
    end
  end
end
