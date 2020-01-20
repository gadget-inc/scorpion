# frozen_string_literal: true

class Crawler::ExecuteCollectScreenshotsCrawlJob < Que::Job
  self.maximum_retry_count = 1
  self.exclusive_execution_lock = true
  self.queue = "crawls"

  def run(property_id:, reason:)
    property = Property.find(property_id)
    Crawler::ExecuteCrawl.new(property.account).collect_screenshots_crawl(property, reason)
  end
end
