# frozen_string_literal: true
class CreateShopifyDataDetectedApps < ActiveRecord::Migration[6.0]
  def change
    create_table :shopify_data_detected_apps do |t|
      t.bigint :account_id, null: false
      t.bigint :shopify_shop_id, null: false
      t.string :name, null: false
      t.datetime :first_seen_at, null: false
      t.datetime :last_seen_at, null: false
      t.boolean :seen_last_time, null: false
      t.string :reasons, null: false, array: true

      t.timestamps
    end

    add_foreign_key :shopify_data_detected_apps, :accounts
    add_foreign_key :shopify_data_detected_apps, :shopify_shops
  end
end
