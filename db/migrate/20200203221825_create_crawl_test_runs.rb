# frozen_string_literal: true
class CreateCrawlTestRuns < ActiveRecord::Migration[6.0]
  def change
    create_table :crawl_test_runs do |t|
      t.string :name, null: false
      t.string :endpoint, null: false
      t.string :started_by, null: false
      t.boolean :running, null: false, default: false
      t.boolean :successful

      t.timestamps
    end
  end
end
