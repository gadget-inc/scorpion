# frozen_string_literal: true
class AddSubjectToAssessmentResults < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!

  def change
    ActiveRecord::Base.connection.execute("TRUNCATE assessment_issues CASCADE;")
    add_column :assessment_results, :subject_type, :string # rubocop:disable Rails/BulkChangeTable
    add_column :assessment_results, :subject_id, :string
  end
end
