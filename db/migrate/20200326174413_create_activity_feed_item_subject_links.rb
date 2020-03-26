# frozen_string_literal: true
class CreateActivityFeedItemSubjectLinks < ActiveRecord::Migration[6.0]
  def change
    # rubocop:disable Rails/CreateTableWithTimestamps
    create_table :activity_feed_item_subject_links do |t|
      t.bigint :account_id, null: false
      t.bigint :activity_feed_item_id, null: false
      t.string :subject_type, null: false
      t.bigint :subject_id, null: false
    end

    add_foreign_key :activity_feed_item_subject_links, :accounts
    add_foreign_key :activity_feed_item_subject_links, :activity_feed_items
    # rubocop:enable Rails/CreateTableWithTimestamps
  end
end
