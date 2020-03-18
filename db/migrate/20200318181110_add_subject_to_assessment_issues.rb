# frozen_string_literal: true
class AddSubjectToAssessmentIssues < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!

  def change
    add_column :assessment_issues, :subject_type, :string # rubocop:disable Rails/BulkChangeTable
    add_column :assessment_issues, :subject_id, :string
    add_column :assessment_issues, :production_scope, :string, null: false, default: "unknown"
    change_column_default :assessment_issues, :production_scope, from: "unknown", to: nil
    add_index :assessment_issues, %i[account_id property_id key key_category closed_at subject_type subject_id], name: "existing_issue_lookup", algorithm: :concurrently
  end
end
