# frozen_string_literal: true
class RemoveHackyInternalRepresentationFromActivityFeedItems < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!

  def change
    ActiveRecord::Base.connection.execute("TRUNCATE activity_feed_items CASCADE;")
    remove_column :activity_feed_items, :hacky_internal_representation, :jsonb
  end
end
