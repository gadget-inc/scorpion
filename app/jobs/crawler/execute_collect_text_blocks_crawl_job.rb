# frozen_string_literal: true

class Crawler::ExecuteCollectTextBlocksCrawlJob < Que::Job
  self.maximum_retry_count = 0
  self.exclusive_execution_lock = true
  self.queue = "crawls"

  def run(property_id:, reason:)
    property = Property.find(property_id)
    crawler = Crawler::ExecuteCrawl.new(property.account)
    attempt = crawler.collect_text_blocks_crawl(property, reason)
    if attempt.succeeded
      SpellCheck::Producer.new(attempt).produce!
    end
  end
end
