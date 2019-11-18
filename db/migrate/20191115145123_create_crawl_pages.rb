# frozen_string_literal: true
class CreateCrawlPages < ActiveRecord::Migration[6.0]
  def change
    create_table :crawl_pages do |t|
      t.bigint :account_id, null: false
      t.bigint :property_id, null: false
      t.bigint :crawl_attempt_id, null: false
      t.string :url, null: false
      t.jsonb :result, null: false

      t.timestamps
    end

    add_foreign_key :crawl_pages, :accounts
    add_foreign_key :crawl_pages, :properties
    add_foreign_key :crawl_pages, :crawl_attempts
  end
end
