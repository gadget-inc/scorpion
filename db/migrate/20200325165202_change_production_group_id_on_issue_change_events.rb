# frozen_string_literal: true
class ChangeProductionGroupIdOnIssueChangeEvents < ActiveRecord::Migration[6.0]
  def change
    # rubocop:disable Rails/BulkChangeTable
    ActiveRecord::Base.connection.execute("TRUNCATE assessment_issue_change_events CASCADE;")
    change_column :assessment_issue_change_events, :assessment_production_group_id, :bigint, null: true
    change_column :assessment_issue_change_events, :assessment_issue_id, :bigint, null: false, default: 0
    change_column_default :assessment_issue_change_events, :assessment_issue_id, from: 0, to: nil
    # rubocop:enable Rails/BulkChangeTable
  end
end
