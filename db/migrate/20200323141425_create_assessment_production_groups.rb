# frozen_string_literal: true
class CreateAssessmentProductionGroups < ActiveRecord::Migration[6.0]
  def change
    create_table :assessment_production_groups do |t|
      t.bigint :account_id, null: false
      t.bigint :property_id, null: false
      t.string :reason, null: false
      t.datetime :started_at, null: false

      t.timestamps
    end

    add_foreign_key :assessment_production_groups, :accounts
    add_foreign_key :assessment_production_groups, :properties
  end
end
