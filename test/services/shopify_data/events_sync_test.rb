# frozen_string_literal: true
require "test_helper"

module ShopifyData
  class EventsSyncTest < ActiveSupport::TestCase
    setup do
      @shop = create(:shopify_shop)
      @sync = ShopifyData::EventsSync.new(@shop, { limit: 5 })
      Timecop.freeze(Time.utc(2020, 3))
    end

    test "it can sync events" do
      assert @shop.data_events.empty?
      @sync.run
      assert_not @shop.data_events.empty?
    end
  end
end
