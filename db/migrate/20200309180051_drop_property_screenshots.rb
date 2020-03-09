# frozen_string_literal: true
class DropPropertyScreenshots < ActiveRecord::Migration[6.0]
  def change
    drop_table :property_screenshots # rubocop:disable Rails/ReversibleMigration
  end
end
