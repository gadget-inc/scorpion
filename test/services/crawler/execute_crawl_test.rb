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
      execute.collect_page_info_crawl(@property, "test")
    end

    test "it gets screenshots for a test shop" do
      execute = ExecuteCrawl.new(@property.account, maxDepth: 1)
      execute.collect_screenshots_crawl(@property, "test")
    end

    test "it gets lighthouses for a test shop" do
      execute = ExecuteCrawl.new(@property.account, maxDepth: 0)
      execute.collect_lighthouse_crawl(@property, "test")
    end

    test "it gets text blocks for a test shop" do
      execute = ExecuteCrawl.new(@property.account, maxDepth: 0)
      execute.collect_text_blocks_crawl(@property, "test")
    end
  end
end
