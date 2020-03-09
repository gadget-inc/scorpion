# frozen_string_literal: true

require "test_helper"

module Crawl
  class LighthouseCrawlerTest < ActiveSupport::TestCase
    test "it crawls a test shop" do
      @property = create(:harry_test_charlie_property)
      @crawler = LighthouseCrawler.new(@property, "test")

      assert_difference "Crawl::Attempt.count", 1 do
        @crawler.collect_lighthouse_crawl
      end

      attempt = @property.crawl_attempts.last
      assert_not_nil attempt.finished_at
      assert attempt.succeeded

      assert_operator 0, :<, @property.assessment_results.size
      url = @property.key_urls.to_a[0].url
      @property.assessment_results.each do |result|
        assert_not_nil result.score
        assert_nil result.error_code
        assert_equal url, result.url
      end
    end

    test "it crawls a shop that can't be connected to exist and logs error results" do
      @property = create(:doesnt_exist_property)
      @crawler = LighthouseCrawler.new(@property, "test")

      assert_difference "Crawl::Attempt.count", 1 do
        @crawler.collect_lighthouse_crawl
      end

      attempt = @property.crawl_attempts.last
      assert_not_nil attempt.finished_at
      assert attempt.succeeded

      url = @property.key_urls.to_a[0].url
      @property.assessment_results.each do |result|
        assert_equal 0, result.score
        assert_not_nil result.error_code
        assert_equal url, result.url
      end
    end
  end
end
