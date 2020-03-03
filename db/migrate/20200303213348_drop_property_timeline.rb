# frozen_string_literal: true

class DropPropertyTimeline < ActiveRecord::Migration[6.0]
  def change
    drop_table :property_timeline_entries # rubocop:disable Rails/ReversibleMigration
  end
end
