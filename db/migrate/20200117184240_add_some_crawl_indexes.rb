# frozen_string_literal: true
class AddSomeCrawlIndexes < ActiveRecord::Migration[6.0]
  def change
    remove_index :crawl_attempts, %i[account_id crawl_type succeeded]
    add_index :crawl_attempts, %i[property_id crawl_type succeeded finished_at], name: "index_crawl_attempts_on_success_and_finished"
    add_index :crawl_pages, "crawl_attempt_id, (result->'error' IS NULL)", name: "index_crawl_pages_on_attempt_and_error"
  end
end
