# frozen_string_literal: true

require "test_helper"

module ShopifyData
  class ThemeAssetSyncTest < ActiveSupport::TestCase
    setup do
      @shop = create(:shopify_shop)
      @sync = ShopifyData::ThemeAssetSync.new(@shop)
      Timecop.freeze(Time.utc(2020, 3))
    end

    test "it can sync theme attribute changes" do
      shopify_theme_id = @shop.with_shopify_session do
        themes = ShopifyAPI::Theme.find(:all)
        theme = themes[0]
        theme.name = "Main Theme"
        theme.save!
        theme.id
      end

      assert @shop.data_themes.empty?

      @sync.run(shopify_theme_id)
      assert_equal 1, @shop.data_themes.size
      data_theme = @shop.data_themes.first

      assert_equal "Main Theme", data_theme.name

      @shop.with_shopify_session do
        theme = ShopifyAPI::Theme.find(shopify_theme_id)
        theme.name = "A New Name"
        theme.save!
      end

      @sync.run(shopify_theme_id)
      assert_equal 1, @shop.data_themes.size
      assert_equal "A New Name", data_theme.reload.name
    end

    test "it can sync theme assets" do
      shopify_theme_id = @shop.with_shopify_session do
        themes = ShopifyAPI::Theme.find(:all)
        themes.to_a[0].id
      end

      assert @shop.data_themes.empty?
      @sync.run(shopify_theme_id)
      assert_equal 1, @shop.data_themes.size
      data_theme = @shop.data_themes.first

      assert_equal @shop.account, data_theme.account
      assert data_theme.name.present?
      assert data_theme.role.present?
      assert data_theme.shopify_created_at.present?
      assert data_theme.shopify_updated_at.present?

      assert_equal 0, data_theme.asset_change_events.size
    end

    test "it picks up changes in assets" do
      shopify_theme_id = @shop.with_shopify_session do
        themes = ShopifyAPI::Theme.find(:all)
        themes.to_a[0].id
      end

      @shop.with_shopify_session do
        ShopifyAPI::Asset.find("assets/test.js", params: { theme_id: shopify_theme_id }).destroy
      rescue ActiveResource::ResourceNotFound # rubocop:disable Lint/SuppressedException
      end

      assert @shop.data_themes.empty?
      @sync.run(shopify_theme_id)
      assert_equal 1, @shop.data_themes.size

      @shop.with_shopify_session do
        new_asset = ShopifyAPI::Asset.new(key: "assets/test.js", theme_id: shopify_theme_id)
        new_asset.value = "console.log('whatever');"
        new_asset.save!
      end

      @sync.run(shopify_theme_id)

      data_theme = @shop.data_themes.first
      assert_equal 1, data_theme.asset_change_events.size
      create_event = data_theme.asset_change_events.first
      assert_equal @shop, create_event.shopify_shop
      assert_equal @shop.account, create_event.account
      assert_equal "assets/test.js", create_event.key
      assert_equal "create", create_event.action

      @shop.with_shopify_session do
        asset = ShopifyAPI::Asset.find("assets/test.js", params: { theme_id: shopify_theme_id })
        asset.value = "console.log('some new stuff');"
        asset.save!
      end

      @sync.run(shopify_theme_id)

      assert_equal 2, data_theme.reload.asset_change_events.size
      update_event = data_theme.reload.asset_change_events.where(action: "update").first
      assert_equal "assets/test.js", update_event.key
      assert_equal "update", update_event.action
      assert_operator update_event.id, :>, create_event.id

      @shop.with_shopify_session do
        ShopifyAPI::Asset.find("assets/test.js", params: { theme_id: shopify_theme_id }).destroy
      end

      @sync.run(shopify_theme_id)

      assert_equal 3, data_theme.reload.asset_change_events.size
      destroy_event = data_theme.reload.asset_change_events.where(action: "destroy").first
      assert_equal "assets/test.js", destroy_event.key
      assert_equal "destroy", destroy_event.action
      assert_operator destroy_event.id, :>, update_event.id
    end
  end
end
