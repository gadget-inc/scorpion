# frozen_string_literal: true
class AddLastHtmlToCrawlTestCases < ActiveRecord::Migration[6.0]
  def change
    add_column :crawl_test_cases, :last_html, :text
  end
end
