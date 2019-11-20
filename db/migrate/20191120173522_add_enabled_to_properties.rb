# frozen_string_literal: true
class AddEnabledToProperties < ActiveRecord::Migration[6.0]
  def change
    change_table :properties, bulk: true do
      add_column :properties, :enabled, :boolean, null: false, default: true
      add_column :properties, :discarded_at, :datetime, null: true
    end
  end
end
