# frozen_string_literal: true

class Crawl::KeyUrlsCrawlJob < Que::Job
  self.maximum_retry_count = 0
  self.exclusive_execution_lock = true
  self.queue = "crawls"

  def run(property_id:, reason:)
    property = Property.find(property_id)
    Crawl::LighthouseCrawler.new(property, reason).collect_lighthouse_crawl
  end
end
