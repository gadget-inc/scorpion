# frozen_string_literal: true
class RemoveLogsFromCrawlTestCases < ActiveRecord::Migration[6.0]
  def change
    remove_column :crawl_test_cases, :logs, :jsonb
  end
end
