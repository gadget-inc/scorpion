# frozen_string_literal: true
class CreatePropertyTimelineEntries < ActiveRecord::Migration[6.0]
  def change
    create_table :property_timeline_entries do |t|
      t.bigint :account_id, null: false
      t.bigint :property_id, null: false
      t.datetime :entry_at, null: false
      t.string :entry_type, null: false
      t.jsonb :entry, null: false

      t.timestamps
    end
  end
end
