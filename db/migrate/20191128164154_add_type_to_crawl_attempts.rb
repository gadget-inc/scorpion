# frozen_string_literal: true

class AddTypeToCrawlAttempts < ActiveRecord::Migration[6.0]
  def change
    add_column :crawl_attempts, :crawl_type, :string, default: "collect_page_info"
    add_index :crawl_attempts, %i[account_id crawl_type succeeded]
  end
end
