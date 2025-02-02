# frozen_string_literal: true
module ShopifyData
  # Knows how to fetch all the new and changed assets for a theme since last time, as well as theme data itself, and save them to the database
  class ThemeAssetSync
    include ShopifyApiRetries
    include Wisper::Publisher

    SYNC_THEME_ATTRIBUTES = %i[processing previewable name role theme_store_id].freeze
    THEME_CHANGE_TRACKED_ATTRIBUTES = %i[name role previewable].freeze

    attr_reader :shop

    def initialize(shop)
      @shop = shop
      @account = shop.account
      @now = Time.now.utc
    end

    def run(remote_theme_id)
      @shop.with_shopify_session do
        api_theme = with_retries { ShopifyAPI::Theme.find(remote_theme_id) }
        data_theme = find_or_initialize_data_theme(api_theme)
        tracker = initial_tracker(data_theme)

        new_assets = with_retries { ShopifyAPI::Asset.find(:all, params: { theme_id: remote_theme_id }) }
        asset_changes, tracker = changed_assets(tracker, new_assets)

        ActiveRecord::Base.transaction do
          data_theme.asset_change_tracker = tracker
          data_theme.save!
          insert_asset_change_events!(data_theme, asset_changes)
          insert_theme_change_events!(data_theme)
        end

        broadcast(:shopify_theme_changed, { shopify_shop_id: @shop.id, shopify_data_theme_id: data_theme.id, property_id: @shop.property_id })
      end
    end

    def find_or_initialize_data_theme(api_theme)
      data_theme = @shop.data_themes.find_or_initialize_by(theme_id: api_theme.id)
      data_theme.shopify_shop = @shop
      data_theme.account = @account
      data_theme.shopify_created_at = api_theme.created_at
      data_theme.shopify_updated_at = api_theme.updated_at
      SYNC_THEME_ATTRIBUTES.each do |attribute|
        data_theme[attribute] = api_theme.send(attribute)
      end

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

    def insert_asset_change_events!(data_theme, asset_changes)
      asset_changes.each do |change|
        change[:shopify_data_theme_id] = data_theme.id
      end
      if !asset_changes.empty?
        ShopifyData::AssetChangeEvent.insert_all!(asset_changes)
      end
    end

    def insert_theme_change_events!(data_theme)
      changes = theme_change_event_attributes(data_theme)
      if !changes.empty?
        ShopifyData::ThemeChangeEvent.insert_all!(changes)
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

    def theme_change_event_attributes(theme_record)
      relevant_changes = theme_record.changes.symbolize_keys.slice(*THEME_CHANGE_TRACKED_ATTRIBUTES)
      relevant_changes.map do |attribute, (old_value, new_value)|
        {
          account_id: @account.id,
          shopify_shop_id: @shop.id,
          shopify_data_theme_id: theme_record.id,
          record_attribute: attribute,
          old_value: old_value,
          new_value: new_value,
          created_at: @now,
          updated_at: @now,
        }
      end
    end
  end
end
