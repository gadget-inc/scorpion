# frozen_string_literal: true
# == Schema Information
#
# Table name: assessment_results
#
#  id                             :bigint           not null, primary key
#  assessment_at                  :datetime         not null
#  details                        :jsonb            not null
#  error_code                     :string
#  key                            :string           not null
#  key_category                   :string           not null
#  production_scope               :string           not null
#  score                          :integer          not null
#  score_mode                     :string           not null
#  subject_type                   :string
#  url                            :string
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#  account_id                     :bigint           not null
#  assessment_production_group_id :bigint           not null
#  issue_id                       :bigint
#  property_id                    :bigint           not null
#  subject_id                     :string
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#  fk_rails_...  (assessment_production_group_id => assessment_production_groups.id)
#  fk_rails_...  (issue_id => assessment_issues.id)
#  fk_rails_...  (property_id => properties.id)
#

# Represents one decision we made about some quality of a property at a point in time. Largely immutable.
class Assessment::Result < ApplicationRecord
  include AccountScoped
  belongs_to :property
  belongs_to :issue, class_name: "Assessment::Issue", optional: true
  belongs_to :production_group, class_name: "Assessment::ProductionGroup", foreign_key: :assessment_production_group_id, inverse_of: :assessment_results

  enum key_category: Assessment::Categories.keys.each_with_object({}) { |key, hash| hash[key] = key.to_s }
end
