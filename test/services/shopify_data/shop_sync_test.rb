# frozen_string_literal: true

require "test_helper"

class ShopifyData::ShopSyncTest < ActiveSupport::TestCase
  setup do
    @shop = create(:live_test_myshopify_shop)
    @sync = ShopifyData::ShopSync.new(@shop)
  end

  test "it can sync a shop" do
    assert @shop.data_shop_change_events.empty?
    @sync.run
    size = @shop.data_shop_change_events.count
    assert_operator 0, :<, size

    @sync.run
    no_changes_size = @shop.data_shop_change_events.count
    assert_equal size, no_changes_size
  end
end
