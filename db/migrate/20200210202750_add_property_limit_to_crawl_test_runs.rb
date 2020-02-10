# frozen_string_literal: true
class AddPropertyLimitToCrawlTestRuns < ActiveRecord::Migration[6.0]
  def change
    add_column :crawl_test_runs, :property_limit, :integer, null: false, default: 50
  end
end
