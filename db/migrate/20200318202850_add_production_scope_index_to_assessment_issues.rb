# frozen_string_literal: true
class AddProductionScopeIndexToAssessmentIssues < ActiveRecord::Migration[6.0]
  def change
    add_index :assessment_issues, %i[account_id property_id production_scope closed_at], name: "existing_issue_cache_lookup", algorithm: :concurrently
  end
end
