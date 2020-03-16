# frozen_string_literal: true
class AddUniqueIndexToShopifyEvents < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!

  def up
    ActiveRecord::Base.connection.execute("TRUNCATE shopify_data_events;")
    add_index :shopify_data_events, :event_id, unique: true
  end

  def down
    remove_index :shopify_data_events, :event_id, unique: true
  end
end
