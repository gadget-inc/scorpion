# frozen_string_literal: true
class AddIssueToAssessmentResults < ActiveRecord::Migration[6.0]
  def change
    # rubocop:disable Rails/BulkChangeTable
    add_column :assessment_results, :issue_id, :bigint, null: true
    add_column :assessment_results, :production_scope, :string, null: false, default: "unknown"
    change_column_default :assessment_results, :production_scope, from: "unknown", to: nil
    add_foreign_key :assessment_results, :assessment_issues, column: :issue_id
    # rubocop:enable Rails/BulkChangeTable
  end
end
