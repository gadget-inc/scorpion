# frozen_string_literal: true

require "test_helper"

class Crawler::ExecuteCrawlTest < ActiveSupport::TestCase
  setup do
    @property = create(:sole_destroyer_property)
  end

  test "it crawls a test shop" do
    execute = Crawler::ExecuteCrawl.new(@property.account, maxDepth: 1)
    execute.crawl(@property, "test")
  end

  test "it can run the background job in k8s" do
    Crawler::ExecuteCrawl.run_in_background(@property, "test", force_kubernetes: true)
  end
end
