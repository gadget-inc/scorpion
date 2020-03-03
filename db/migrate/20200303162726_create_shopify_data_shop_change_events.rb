# frozen_string_literal: true
class CreateShopifyDataShopChangeEvents < ActiveRecord::Migration[6.0]
  def change
    create_table :shopify_data_shop_change_events do |t|
      t.bigint :account_id, null: false
      t.bigint :shopify_shop_id, null: false
      t.string :record_attribute, null: false
      t.jsonb :old_value
      t.jsonb :new_value
      t.timestamps
    end

    add_foreign_key :shopify_data_shop_change_events, :accounts
    add_foreign_key :shopify_data_shop_change_events, :shopify_shops
  end
end
