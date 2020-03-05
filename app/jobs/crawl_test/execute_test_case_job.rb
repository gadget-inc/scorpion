# frozen_string_literal: true

module CrawlTest
  class ExecuteTestCaseJob < Que::Job
    include SemanticLogger::Loggable

    self.maximum_retry_count = 0
    self.exclusive_execution_lock = true
    self.queue = "crawl_tests"

    def run(crawl_test_case_id:)
      test_case = Case.find(crawl_test_case_id)
      Tester.new.execute_case(test_case)
    rescue Crawl::CrawlerClient::CrawlExecutionError => e
      logger.error("Crawl test case failed to execute with error", e)
    end
  end
end
