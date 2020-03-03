# frozen_string_literal: true
module ShopifyData
  # Knows how to fetch all the new and changed assets for a theme since last time, as well as theme data itself, and save them to the database
  class ThemeAssetSync
    include ShopifyApiRetries
    attr_reader :shop

    def initialize(shop)
      @shop = shop
      @account = shop.account
      @now = Time.now.utc
    end

    def run(shopify_theme_id)
      @shop.with_shopify_session do
        api_theme = with_retries { ShopifyAPI::Theme.find(shopify_theme_id) }
        data_theme = find_or_initialize_data_theme(api_theme)
        tracker = initial_tracker(data_theme)

        new_assets = with_retries { ShopifyAPI::Asset.find(:all, params: { theme_id: shopify_theme_id }) }
        changes, tracker = changed_assets(tracker, new_assets)

        ActiveRecord::Base.transaction do
          data_theme.asset_change_tracker = tracker
          data_theme.save!
          insert_change_events(data_theme, changes)
        end
      end
    end

    def find_or_initialize_data_theme(api_theme)
      data_theme = @shop.data_themes.find_or_initialize_by(theme_id: api_theme.id)
      data_theme.shopify_shop = @shop
      data_theme.account = @account
      data_theme.name = api_theme.name
      data_theme.role = api_theme.role
      data_theme.shopify_created_at = api_theme.created_at
      data_theme.shopify_updated_at = api_theme.updated_at
      data_theme.theme_store_id = api_theme.theme_store_id

      data_theme
    end

    def changed_assets(tracker, new_assets)
      changes = []
      seen = Set.new
      tracker = tracker.clone
      new_assets.each do |asset|
        last_track = tracker[asset.key]

        if !last_track
          changes << {
            key: asset.key,
            action: "create",
            action_at: asset.updated_at,
          }
        elsif last_track["updated_at"] < asset.updated_at
          changes << {
            key: asset.key,
            action: "update",
            action_at: asset.updated_at,
          }
        end

        tracker[asset.key] = tracker_entry_for_asset(asset)
        seen.add(asset.key)
      end

      (Set.new(tracker.keys) - seen).each do |deleted_key|
        changes << {
          key: deleted_key,
          action: "destroy",
          action_at: @now,
        }
      end

      changes.each do |change|
        change[:account_id] = @account.id
        change[:shopify_shop_id] = @shop.id
      end

      [changes, tracker]
    end

    def insert_change_events(data_theme, changes)
      changes.each do |change|
        change[:shopify_data_theme_id] = data_theme.id
      end
      if !changes.empty?
        ShopifyData::AssetChangeEvent.insert_all!(changes)
      end
    end

    def initial_tracker(data_theme)
      if data_theme.asset_change_tracker.blank?
        assets = with_retries { ShopifyAPI::Asset.find(:all, params: { theme_id: @theme_id }) }
        assets.each_with_object({}) do |asset, tracker|
          tracker[asset.key] = tracker_entry_for_asset(asset)
        end
      else
        data_theme.asset_change_tracker
      end
    end

    def tracker_entry_for_asset(asset_blob)
      {
        "updated_at" => asset_blob.updated_at,
        "content_type" => asset_blob.content_type,
        "public_url" => asset_blob.public_url,
      }
    end
  end
end
