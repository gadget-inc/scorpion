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
#  assessment_issue_id            :bigint           not null
#  assessment_production_group_id :bigint
#  property_id                    :bigint           not null
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#  fk_rails_...  (assessment_issue_id => assessment_issues.id)
#  fk_rails_...  (assessment_production_group_id => assessment_production_groups.id)
#  fk_rails_...  (property_id => properties.id)
#
require "test_helper"

class Assessment::IssueChangeEventTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
