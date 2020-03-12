# frozen_string_literal: true
class CreateAssessmentDescriptors < ActiveRecord::Migration[6.0]
  def change
    create_table :assessment_descriptors do |t|
      t.string :key, null: false, index: { unique: true }
      t.string :title, null: false
      t.string :severity, null: false
      t.string :description, null: false

      t.timestamps
    end
  end
end
