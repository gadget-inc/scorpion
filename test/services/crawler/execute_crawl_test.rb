# frozen_string_literal: true

require "test_helper"

module Crawler
  class ExecuteCrawlTest < ActiveSupport::TestCase
    setup do
      @property = create(:sole_destroyer_property)
      CrawlerClient.client.stubs(:block_until_available).returns(true)
    end

    test "it crawls a test shop" do
      execute = ExecuteCrawl.new(@property.account, maxDepth: 1)
      execute.crawl(@property, "test")
    end

    test "it can run the background job in k8s" do
      ExecuteCrawl.run_in_background(@property, "test", force_kubernetes: true)
    end
  end
end
