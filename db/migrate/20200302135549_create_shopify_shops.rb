# frozen_string_literal: true

class CreateShopifyShops < ActiveRecord::Migration[6.0]
  def self.up
    create_table :shopify_shops do |t|
      t.string :domain, null: false
      t.string :api_token, null: false
      t.bigint :property_id, null: false
      t.bigint :account_id, null: false
      t.bigint :creator_id, null: true
      t.timestamps
    end

    add_index :shopify_shops, :domain, unique: true
    add_foreign_key :shopify_shops, :properties
    add_foreign_key :shopify_shops, :accounts
    add_foreign_key :shopify_shops, :users, column: :creator_id
  end

  def self.down
    drop_table :shopify_shops
  end
end
