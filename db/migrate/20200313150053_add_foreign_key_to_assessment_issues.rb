# frozen_string_literal: true
class AddForeignKeyToAssessmentIssues < ActiveRecord::Migration[6.0]
  def change
    add_foreign_key :assessment_issues, :assessment_descriptors, column: :key, primary_key: :key
  end
end
