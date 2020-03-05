# frozen_string_literal: true

require "test_helper"

module Activity
  class FeedProducerTest < ActiveSupport::TestCase
    setup do
      @property = create(:property)
      @shop = create(:shopify_shop, property: @property, account: @property.account)
      @producer = FeedProducer.new(@property)
      Timecop.freeze(Time.utc(2020, 3))
    end

    test "it produces no feed items if there are no changes" do
      @producer.produce
      @producer.produce
      assert_equal 0, @property.activity_feed_items.size
    end

    test "it produces feed items with unprocessed source data" do
      create(:shopify_data_shop_change_event, record_attribute: "name", new_value: "Cool Shop", account: @property.account, shopify_shop: @shop)
      create(:shopify_data_shop_change_event, record_attribute: "customer_email", new_value: "test@test.com", account: @property.account, shopify_shop: @shop)

      assert_difference "Activity::FeedItem.count" do
        @producer.produce
      end

      first_feed_item = @property.activity_feed_items.first
      assert_equal 2, first_feed_item.hacky_internal_representation["events"].size

      # travel a month ahead
      Timecop.freeze(Time.utc(2020, 4))
      create(:shopify_data_shop_change_event, record_attribute: "name", new_value: "Really Cool Shop", account: @property.account, shopify_shop: @shop)
      assert_difference "Activity::FeedItem.count" do
        @producer.produce
      end

      second_feed_item = @property.activity_feed_items.order("created_at DESC").first
      assert_not_equal first_feed_item, second_feed_item
      assert_operator second_feed_item.item_at, :>, first_feed_item.item_at
      assert_equal 1, second_feed_item.hacky_internal_representation["events"].size
      assert_equal 2, first_feed_item.reload.hacky_internal_representation["events"].size

      # travel a month ahead and make sure producing again doesnt create changes
      Timecop.freeze(Time.utc(2020, 5))
      assert_no_difference "Activity::FeedItem.count" do
        @producer.produce
      end
    end

    test "it folds unprocessed source data into existing feed items if it's within the threshold" do
      create(:shopify_data_shop_change_event, record_attribute: "name", new_value: "Cool Shop", account: @property.account, shopify_shop: @shop)
      create(:shopify_data_shop_change_event, record_attribute: "customer_email", new_value: "test@test.com", account: @property.account, shopify_shop: @shop)

      assert_difference "Activity::FeedItem.count" do
        @producer.produce
      end

      first_feed_item = @property.activity_feed_items.first
      assert_equal 2, first_feed_item.hacky_internal_representation["events"].size

      # travel a minute ahead
      Timecop.freeze(Time.now.utc + 1.minute)
      create(:shopify_data_shop_change_event, record_attribute: "name", new_value: "Really Cool Shop", account: @property.account, shopify_shop: @shop)
      assert_no_difference "Activity::FeedItem.count" do
        @producer.produce
      end

      assert_equal 3, first_feed_item.reload.hacky_internal_representation["events"].size
    end

    test "it produces feed items with newly arrived items" do
      shopify_theme_id = @shop.with_shopify_session do
        themes = ShopifyAPI::Theme.find(:all)
        theme = themes[0]
        theme.name = "Main Theme"
        theme.save!
        theme.id
      end

      with_synchronous_jobs do
        ShopifyData::AllSync.new(@shop).run
      end

      @producer.produce

      @shop.with_shopify_session do
        theme = ShopifyAPI::Theme.find(shopify_theme_id)
        theme.name = "A New Name"
        theme.save!

        begin
          ShopifyAPI::Asset.find("assets/test.js", params: { theme_id: shopify_theme_id }).destroy
        rescue ActiveResource::ResourceNotFound # rubocop:disable Lint/SuppressedException
        end

        new_asset = ShopifyAPI::Asset.new(key: "assets/test.js", theme_id: shopify_theme_id)
        new_asset.value = "console.log('whatever');"
        new_asset.save!
      end

      ShopifyData::ThemeAssetSync.new(@shop).run(shopify_theme_id)
      @producer.produce
      assert_operator 0, :<, @property.reload.activity_feed_items.size
    end
  end
end
