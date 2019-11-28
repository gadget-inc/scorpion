# frozen_string_literal: true

require "test_helper"

module Crawler
  class ExecuteCrawlTest < ActiveSupport::TestCase
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
  end
end
