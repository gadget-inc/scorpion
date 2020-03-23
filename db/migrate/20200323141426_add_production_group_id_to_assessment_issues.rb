# frozen_string_literal: true
class AddProductionGroupIdToAssessmentIssues < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!

  def change
    # rubocop:disable Rails/BulkChangeTable
    ActiveRecord::Base.connection.execute("TRUNCATE assessment_results CASCADE;")
    add_column :assessment_results, :assessment_production_group_id, :bigint, null: false, default: 0
    change_column_default :assessment_results, :assessment_production_group_id, from: 0, to: nil
    add_foreign_key :assessment_results, :assessment_production_groups

    ActiveRecord::Base.connection.execute("TRUNCATE assessment_issue_change_events CASCADE;")
    add_column :assessment_issue_change_events, :assessment_production_group_id, :bigint, null: false, default: 0
    change_column_default :assessment_issue_change_events, :assessment_production_group_id, from: 0, to: nil
    add_foreign_key :assessment_issue_change_events, :assessment_production_groups
    # rubocop:enable Rails/BulkChangeTable
  end
end
