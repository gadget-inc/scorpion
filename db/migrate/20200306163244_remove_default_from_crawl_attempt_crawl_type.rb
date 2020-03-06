# frozen_string_literal: true
class RemoveDefaultFromCrawlAttemptCrawlType < ActiveRecord::Migration[6.0]
  def change
    change_column_default :crawl_attempts, :crawl_type, from: "collect_page_info", to: nil
  end
end
