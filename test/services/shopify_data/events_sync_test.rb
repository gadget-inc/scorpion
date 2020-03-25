# frozen_string_literal: true
require "test_helper"

class ShopifyData::EventsSyncTest < ActiveSupport::TestCase
  setup do
    @shop = create(:live_test_myshopify_shop)
    @sync = ShopifyData::EventsSync.new(@shop, { limit: 5 })
    Timecop.freeze(Time.utc(2020, 3))
  end

  test "it can sync events" do
    assert @shop.data_events.empty?
    @sync.run
    assert_not @shop.data_events.empty?

    # run the sync again immediately after and ensure no duplicates are created
    assert_no_difference "@shop.data_events.count" do
      @sync.run
    end
  end
end
