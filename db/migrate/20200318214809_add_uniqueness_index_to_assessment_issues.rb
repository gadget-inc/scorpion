# frozen_string_literal: true
class AddUniquenessIndexToAssessmentIssues < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!

  def change
    ActiveRecord::Base.connection.execute("TRUNCATE assessment_issues CASCADE;")
    add_index :assessment_issues, %i[account_id number], unique: true
  end
end
