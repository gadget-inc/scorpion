# frozen_string_literal: true
class CreateActivityFeedItems < ActiveRecord::Migration[6.0]
  def change
    create_table :activity_feed_items do |t|
      t.bigint :account_id, null: false
      t.bigint :property_id, null: false
      t.string :item_type, null: false
      t.datetime :item_at, null: false
      t.datetime :group_start
      t.datetime :group_end
      t.jsonb :hacky_internal_representation

      t.timestamps
    end

    add_foreign_key :activity_feed_items, :accounts
    add_foreign_key :activity_feed_items, :properties
    add_index :activity_feed_items, %i[account_id property_id item_at], name: "idx_feed_time_lookup"
  end
end
