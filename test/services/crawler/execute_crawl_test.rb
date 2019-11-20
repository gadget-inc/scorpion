# frozen_string_literal: true

require "test_helper"

class Crawler::ExecuteCrawlTest < ActiveSupport::TestCase
  test "it crawls a test shop" do
    property = create(:sole_destroyer_property)
    execute = Crawler::ExecuteCrawl.new(property.account, maxDepth: 1)

    execute.crawl(property, "test")
  end
end
