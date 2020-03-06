# frozen_string_literal: true
class CreateAssessmentResults < ActiveRecord::Migration[6.0]
  def change
    create_table :assessment_results do |t|
      t.bigint :account_id, null: false
      t.bigint :property_id, null: false
      t.datetime :assessment_at, null: false
      t.string :key, null: false
      t.string :key_category, null: false
      t.integer :score, null: false
      t.string :score_mode, null: false
      t.string :error_code, null: true

      t.string :url
      t.jsonb :details, null: false, default: {}

      t.timestamps
    end

    add_foreign_key :assessment_results, :accounts
    add_foreign_key :assessment_results, :properties
  end
end
