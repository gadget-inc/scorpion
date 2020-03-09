# frozen_string_literal: true

require "test_helper"

module Crawl
  class InfrastructureTest < ActiveSupport::TestCase
    setup do
      create(:live_test_myshopify_property)
      create(:ambient_homesick_property)
    end

    test "it runs medium frequency enqueues for crawlable properties" do
      assert_difference "Crawl::Attempt.all.size", 1 do
        with_synchronous_jobs do
          Infrastructure::PeriodicMediumFrequencyEnqueueJob.run
        end
      end
    end

    test "it runs high frequency enqueues for key urls" do
      assert_difference "Crawl::Attempt.all.size", 1 do
        with_synchronous_jobs do
          Infrastructure::PeriodicHighFrequencyEnqueueJob.run
        end
      end
    end

    test "it marks crawl attempts whos workers were killed as failed" do
      attempt = create(:crawl_attempt, last_progress_at: 1.hour.ago, started_at: 1.hour.ago, running: true)
      assert attempt.running

      Infrastructure::PeriodicMarkFailedCrawlAttemptsJob.run
      attempt.reload

      assert_not attempt.succeeded
      assert_not attempt.running
      assert attempt.finished_at.present?
    end
  end
end
