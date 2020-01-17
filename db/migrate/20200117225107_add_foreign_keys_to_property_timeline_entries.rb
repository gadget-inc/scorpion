# frozen_string_literal: true
class AddForeignKeysToPropertyTimelineEntries < ActiveRecord::Migration[6.0]
  def change
    add_foreign_key :property_timeline_entries, :accounts
    add_foreign_key :property_timeline_entries, :properties
  end
end
