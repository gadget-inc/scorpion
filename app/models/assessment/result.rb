# frozen_string_literal: true
# == Schema Information
#
# Table name: assessment_results
#
#  id               :bigint           not null, primary key
#  assessment_at    :datetime         not null
#  details          :jsonb            not null
#  error_code       :string
#  key              :string           not null
#  key_category     :string           not null
#  production_scope :string           not null
#  score            :integer          not null
#  score_mode       :string           not null
#  url              :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  account_id       :bigint           not null
#  issue_id         :bigint
#  property_id      :bigint           not null
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#  fk_rails_...  (issue_id => assessment_issues.id)
#  fk_rails_...  (property_id => properties.id)
#

# Represents one decision we made about some quality of a property at a point in time. Largely immutable.
class Assessment::Result < ApplicationRecord
  include AccountScoped
  belongs_to :property
  belongs_to :issue, class_name: "Assessment::Issue", optional: true

  enum key_category: Assessment::Categories.keys.each_with_object({}) { |key, hash| hash[key] = key.to_s }
end
