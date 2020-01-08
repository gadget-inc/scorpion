# frozen_string_literal: true

require "test_helper"

module Crawler
  class InfrastructureTest < ActiveSupport::TestCase
    setup do
      @property = create(:sole_destroyer_property)
      CrawlerClient.client.stubs(:block_until_available).returns(true)
      ExecuteCrawl.any_instance.stubs(:crawl_options).returns(maxDepth: 1)  # so e2e crawling tests don't take forever
    end

    test "it crawls all shops for page info in the background" do
      with_synchronous_jobs do
        Infrastructure::PeriodicEnqueueCollectPageInfoCrawlsJob.run
      end
    end

    test "it crawls all shops for screenshots in the background" do
      with_synchronous_jobs do
        Infrastructure::PeriodicEnqueueCollectScreenshotsCrawlsJob.run
      end
    end

    test "it crawls all shops for lighthouses in the background" do
      with_synchronous_jobs do
        Infrastructure::PeriodicEnqueueCollectLighthouseCrawlsJob.run
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
