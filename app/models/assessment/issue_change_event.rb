# frozen_string_literal: true
# == Schema Information
#
# Table name: assessment_issue_change_events
#
#  id                             :bigint           not null, primary key
#  action                         :string           not null
#  action_at                      :datetime         not null
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#  account_id                     :bigint           not null
#  assessment_issue_id            :bigint
#  assessment_production_group_id :bigint           not null
#  property_id                    :bigint           not null
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#  fk_rails_...  (assessment_issue_id => assessment_issues.id)
#  fk_rails_...  (assessment_production_group_id => assessment_production_groups.id)
#  fk_rails_...  (property_id => properties.id)
#
module Assessment
  # Represents one user-important change to the state of an issue. Powers timelines.
  class IssueChangeEvent < ApplicationRecord
    include AccountScoped
    belongs_to :property
    belongs_to :issue, class_name: "Assessment::Issue", foreign_key: :assessment_issue_id, inverse_of: :issue_change_events
    belongs_to :production_group, optional: true, class_name: "Assessment::ProductionGroup", foreign_key: :assessment_production_group_id, inverse_of: :issue_change_events
  end
end
