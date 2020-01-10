# frozen_string_literal: true

class Infrastructure::PeriodicEnqueueCollectLighthouseCrawlsJob < Que::Job
  self.exclusive_execution_lock = true

  def run
    Property.for_purposeful_crawls.find_each do |property|
      Crawler::ExecuteCrawl.run_in_background(property, "scheduled", :collect_lighthouse)
    end
  end

  def log_level(_elapsed)
    :info
  end
end
