# frozen_string_literal: true
class CreateShopifyDataEvents < ActiveRecord::Migration[6.0]
  def change
    create_table :shopify_data_events do |t|
      t.bigint :account_id, null: false
      t.bigint :shopify_shop_id, null: false
      t.bigint :event_id, null: false
      t.bigint :subject_id, null: false
      t.string :verb, null: false
      t.string :path
      t.string :author
      t.string :body
      t.string :description
      t.string :arguments
      t.datetime :shopify_created_at, null: false

      t.timestamps
    end

    add_foreign_key :shopify_data_events, :accounts
    add_foreign_key :shopify_data_events, :shopify_shops
  end
end
