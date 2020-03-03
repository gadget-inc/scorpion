# frozen_string_literal: true
class CreateShopifyDataThemes < ActiveRecord::Migration[6.0]
  def change
    create_table :shopify_data_themes do |t|
      t.bigint :account_id, null: false
      t.bigint :shopify_shop_id, null: false
      t.bigint :theme_id, null: false
      t.string :name, null: false
      t.string :role, null: false
      t.bigint :theme_store_id
      t.datetime :shopify_created_at, null: false
      t.datetime :shopify_updated_at, null: false
      t.jsonb :asset_change_tracker, null: false, default: {}

      t.timestamps
    end

    add_foreign_key :shopify_data_themes, :accounts
    add_foreign_key :shopify_data_themes, :shopify_shops
  end
end
