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

    test "it produces feed items with no prior items" do
      @producer.produce
      @producer.produce
      assert_equal 0, @property.activity_feed_items.size
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
