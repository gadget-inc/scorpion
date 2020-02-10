# frozen_string_literal: true
class AddCriteriaToCrawlTestRuns < ActiveRecord::Migration[6.0]
  def change
    add_column :crawl_test_runs, :property_criteria, :string
  end
end
