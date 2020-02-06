# frozen_string_literal: true
class CreateCrawlTestCases < ActiveRecord::Migration[6.0]
  def change
    create_table :crawl_test_cases do |t|
      t.bigint :crawl_test_run_id, null: false
      t.bigint :property_id, null: false, index: true
      t.timestamp :started_at
      t.timestamp :finished_at
      t.boolean :running, null: false, default: false
      t.boolean :successful

      t.jsonb :logs, null: false, default: []
      t.jsonb :error, null: true
      t.timestamps
    end

    add_foreign_key :crawl_test_cases, :crawl_test_runs
  end
end
