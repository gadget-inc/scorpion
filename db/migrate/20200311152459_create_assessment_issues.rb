# frozen_string_literal: true
class CreateAssessmentIssues < ActiveRecord::Migration[6.0]
  def change
    create_table :assessment_issues do |t|
      t.bigint :account_id, null: false
      t.bigint :property_id, null: false
      t.integer :number, null: false
      t.datetime :opened_at, null: false
      t.datetime :last_seen_at, null: false
      t.datetime :closed_at
      t.string :key, null: false
      t.string :key_category, null: false

      t.timestamps
    end

    add_foreign_key :assessment_issues, :accounts
    add_foreign_key :assessment_issues, :properties
  end
end
