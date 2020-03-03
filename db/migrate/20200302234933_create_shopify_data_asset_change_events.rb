# frozen_string_literal: true
class CreateShopifyDataAssetChangeEvents < ActiveRecord::Migration[6.0]
  def change
    create_table :shopify_data_asset_change_events do |t| # rubocop:disable Rails/CreateTableWithTimestamps
      t.bigint :account_id, null: false
      t.bigint :shopify_shop_id, null: false
      t.bigint :shopify_data_theme_id, null: false
      t.string :key, null: false
      t.string :action
      t.datetime :action_at, null: false
    end

    add_foreign_key :shopify_data_asset_change_events, :accounts
    add_foreign_key :shopify_data_asset_change_events, :shopify_shops
    add_foreign_key :shopify_data_asset_change_events, :shopify_data_themes
  end
end
