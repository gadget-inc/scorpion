# frozen_string_literal: true
class CreateCrawlAttempts < ActiveRecord::Migration[6.0]
  def change
    create_table :crawl_attempts do |t|
      t.bigint :account_id, null: false
      t.bigint :property_id, null: false
      t.string :started_reason, null: false
      t.boolean :running, null: false, default: false
      t.boolean :succeeded

      t.datetime :started_at
      t.datetime :last_progress_at
      t.datetime :finished_at
      t.string :failure_reason

      t.timestamps
    end

    add_foreign_key :crawl_attempts, :accounts
    add_foreign_key :crawl_attempts, :properties
  end
end
