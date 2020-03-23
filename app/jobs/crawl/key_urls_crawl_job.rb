# frozen_string_literal: true

class Crawl::KeyUrlsCrawlJob < Que::Job
  self.maximum_retry_count = 0
  self.exclusive_execution_lock = true
  self.queue = "crawls"

  def run(property_id:, production_group_id:)
    property = Property.find(property_id)
    production_group = Assessment::ProductionGroup.find(production_group_id)
    Crawl::LighthouseCrawler.new(property, production_group).collect_lighthouse_crawl
  end
end
