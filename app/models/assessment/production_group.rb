# frozen_string_literal: true
# == Schema Information
#
# Table name: assessment_production_groups
#
#  id          :bigint           not null, primary key
#  reason      :string           not null
#  started_at  :datetime         not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  account_id  :bigint           not null
#  property_id :bigint           not null
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#  fk_rails_...  (property_id => properties.id)
#
module Assessment
  # Represents a stable identifier for a bunch of assessments and issue changes being generated in different pieces of infrastructure. Called a scan to customers.
  class ProductionGroup < ApplicationRecord
    include AccountScoped
    belongs_to :property
    has_many :issue_change_events, class_name: "Assessment::IssueChangeEvent", foreign_key: :assessment_production_group_id, dependent: :destroy, inverse_of: :production_group
    has_many :assessment_results, class_name: "Assessment::Result", foreign_key: :assessment_production_group_id, dependent: :destroy, inverse_of: :production_group
  end
end
