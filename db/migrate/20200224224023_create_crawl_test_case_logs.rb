# frozen_string_literal: true
class CreateCrawlTestCaseLogs < ActiveRecord::Migration[6.0]
  def change
    create_table :crawl_test_case_logs do |t|
      t.bigint :crawl_test_case_id, null: false
      t.string :message, null: false
      t.jsonb :metadata

      t.timestamps
    end

    add_foreign_key :crawl_test_case_logs, :crawl_test_cases
  end
end
