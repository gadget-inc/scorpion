# frozen_string_literal: true
class CreateShopifyDataThemeChangeEvents < ActiveRecord::Migration[6.0]
  def change
    create_table :shopify_data_theme_change_events do |t|
      t.bigint :account_id, null: false
      t.bigint :shopify_shop_id, null: false
      t.bigint :shopify_data_theme_id, null: false
      t.string :record_attribute, null: false
      t.jsonb :new_value
      t.jsonb :old_value

      t.timestamps
    end

    add_foreign_key :shopify_data_theme_change_events, :accounts
    add_foreign_key :shopify_data_theme_change_events, :shopify_shops
    add_foreign_key :shopify_data_theme_change_events, :shopify_data_themes
    add_index :shopify_data_theme_change_events, %i[account_id shopify_shop_id created_at], name: "idx_theme_changes_cursor_lookup"
  end
end
