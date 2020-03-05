# frozen_string_literal: true
class SetGroupStartNonNullableOnActivityFeedItems < ActiveRecord::Migration[6.0]
  def change
    ActiveRecord::Base.connection.execute("TRUNCATE activity_feed_items")
    change_column :activity_feed_items, :group_start, :datetime, null: false # rubocop:disable Rails/BulkChangeTable
    change_column :activity_feed_items, :group_end, :datetime, null: false
  end
end
