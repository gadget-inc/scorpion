# frozen_string_literal: true
class AddProductionScopeIndexToAssessmentIssues < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!

  def change
    ActiveRecord::Base.connection.execute("TRUNCATE assessment_issues CASCADE;")
    add_index :assessment_issues, %i[account_id property_id production_scope closed_at], name: "existing_issue_cache_lookup", algorithm: :concurrently
  end
end
