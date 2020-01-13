# frozen_string_literal: true
require "test_helper"

class Timeline::ScreenshotDiffTest < ActiveSupport::TestCase
  setup do
    @property = create(:sole_destroyer_property)
    @crawler = Crawler::ExecuteCrawl.new(@property.account)
    @producer = Timeline::Producer.new(@property)
  end

  test "there's no difference between two successive screenshots" do
    # take two screenshots
    @crawler.collect_screenshots_crawl(@property, "test")
    @crawler.collect_screenshots_crawl(@property, "test")

    # process timeline
    assert_difference -> { @property.reload.property_timeline_entries.size }, 0 do
      @producer.produce!
    end
  end

  test "there's a difference between two successive screenshots where the underlying content changes" do
    # take a before screenshot
    @crawler.collect_screenshots_crawl(@property, "test")
    # fudge the content changing by changing the url of the site
    @property.crawl_roots = ["https://sole-destroyer.myshopify.com/collections/frontpage/products/classic-varsity-top"]
    @property.save!
    @crawler.collect_screenshots_crawl(@property, "test")

    # process timeline
    # process timeline
    assert_difference -> { @property.reload.property_timeline_entries.size }, 1 do
      @producer.produce!
    end
  end
end
