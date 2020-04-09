# frozen_string_literal: true
require "test_helper"

class ShopifyData::AppDetectorTest < ActiveSupport::TestCase
  setup do
    @shop = create(:live_test_myshopify_shop)
    @detector = ShopifyData::AppDetector.new(@shop)
    ShopifyData::AppStoreScrapeImporter.new(Rails.root.join("db", "shopify-app-store-crawl.csv"), limit: 100).import
  end

  test "it can detect apps" do
    assert_difference "@shop.detected_apps.size", 1 do
      @detector.detect
    end

    assert detected_app = @shop.detected_apps.last
    assert_equal @shop.account, detected_app.account
    assert_equal "Superspeed", detected_app.name
    assert_operator 0, :<, detected_app.reasons.size

    assert event = detected_app.detected_app_change_events.first
    assert_equal "detected", event.action
  end

  test "it detects from a url to a third party web entity" do
    assert_difference "@shop.detected_apps.size", 1 do
      @detector.detect_from_request_urls(["https://www.googletagmanager.com/gtag/js"])
    end

    assert detected_app = @shop.detected_apps.last
    assert_equal "Google Tag Manager", detected_app.name
  end

  test "it detects from a url using a domain inferred to be from a shopify app using the app store crawl" do
    assert_difference "@shop.detected_apps.size", 1 do
      @detector.detect_from_request_urls(["https://gifthy.io/made/up/script/tag.js"])
    end

    assert detected_app = @shop.detected_apps.last
    assert_equal "Gifthy.io", detected_app.name
    assert_equal "Gifthy.io", detected_app.app_store_app.title
  end
end
