# frozen_string_literal: true
require "test_helper"

class ShopifyData::AppDetectorTest < ActiveSupport::TestCase
  setup do
    @shop = create(:live_test_myshopify_shop)
    @detector = ShopifyData::AppDetector.new(@shop)
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
end
