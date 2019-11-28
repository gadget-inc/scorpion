# frozen_string_literal: true
class CreatePropertyScreenshots < ActiveRecord::Migration[6.0]
  def change
    create_table :property_screenshots do |t|
      t.bigint :account_id, null: false
      t.bigint :property_id, null: false
      t.bigint :crawl_attempt_id, null: false
      t.string :url, null: false
      t.jsonb :result, null: false

      t.timestamps
    end

    add_foreign_key :property_screenshots, :accounts
    add_foreign_key :property_screenshots, :properties
    add_foreign_key :property_screenshots, :crawl_attempts
  end
end
