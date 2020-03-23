# frozen_string_literal: true
class CreateAssessmentIssueChangeEvents < ActiveRecord::Migration[6.0]
  def change
    create_table :assessment_issue_change_events do |t|
      t.bigint :account_id, null: false
      t.bigint :property_id, null: false
      t.bigint :assessment_issue_id
      t.string :action, null: false
      t.datetime :action_at, null: false

      t.timestamps
    end

    add_foreign_key :assessment_issue_change_events, :accounts
    add_foreign_key :assessment_issue_change_events, :properties
    add_foreign_key :assessment_issue_change_events, :assessment_issues
  end
end
