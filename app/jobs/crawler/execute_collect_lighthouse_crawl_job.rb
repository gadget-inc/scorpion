# frozen_string_literal: true

class Crawler::ExecuteCollectLighthouseCrawlJob < Que::Job
  self.maximum_retry_count = 0
  self.exclusive_execution_lock = true
  self.queue = "crawls"

  def run(property_id:, reason:)
    property = Property.find(property_id)
    Crawler::ExecuteCrawl.new(property.account).collect_lighthouse_crawl(property, reason)
  end
end
