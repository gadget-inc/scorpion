# frozen_string_literal: true
class CreateShopifyDataDetectedAppChangeEvents < ActiveRecord::Migration[6.0]
  def change
    create_table :shopify_data_detected_app_change_events do |t|
      t.bigint :account_id, null: false
      t.bigint :shopify_shop_id, null: false
      t.bigint :shopify_data_detected_app_id, null: false
      t.string :action, null: false
      t.datetime :action_at, null: false

      t.timestamps
    end

    add_foreign_key :shopify_data_detected_app_change_events, :accounts
    add_foreign_key :shopify_data_detected_app_change_events, :shopify_shops
    add_foreign_key :shopify_data_detected_app_change_events, :shopify_data_detected_apps
  end
end
