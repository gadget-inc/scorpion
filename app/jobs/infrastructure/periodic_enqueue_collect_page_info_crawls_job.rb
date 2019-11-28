# frozen_string_literal: true

class Infrastructure::PeriodicEnqueueCollectPageInfoCrawlsJob < Que::Job
  def run
    Property.kept.where(enabled: true).find_each do |property|
      Crawler::ExecuteCrawl.run_in_background(property, "scheduled", :collect_page_info)
    end
  end

  def log_level(_elapsed)
    :info
  end
end
