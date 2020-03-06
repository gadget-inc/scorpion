# frozen_string_literal: true
class DropCrawlPages < ActiveRecord::Migration[6.0]
  def change
    drop_table :crawl_pages # rubocop:disable Rails/ReversibleMigration
  end
end
