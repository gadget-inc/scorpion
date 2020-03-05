# frozen_string_literal: true

class Infrastructure::PeriodicMarkFailedCrawlAttemptsJob < Que::Job
  self.exclusive_execution_lock = true

  def run
    Crawl::Attempt.where(running: true).where("last_progress_at < ?", 30.minutes.ago).find_each do |attempt|
      attempt.update!(finished_at: Time.now.utc, running: false, succeeded: false, failure_reason: "worker stopped making progress, timed out")
    end
  end

  def log_level(_elapsed)
    :info
  end
end
