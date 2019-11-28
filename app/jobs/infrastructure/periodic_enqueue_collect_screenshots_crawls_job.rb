# frozen_string_literal: true

class Infrastructure::PeriodicEnqueueCollectScreenshotsCrawlsJob < Que::Job
  self.exclusive_execution_lock = true

  def run
    Property.kept.where(enabled: true).find_each do |property|
      Crawler::ExecuteCrawl.run_in_background(property, "scheduled", :collect_screenshots)
    end
  end

  def log_level(_elapsed)
    :info
  end
end
