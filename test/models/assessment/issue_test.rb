# frozen_string_literal: true
# == Schema Information
#
# Table name: assessment_issues
#
#  id               :bigint           not null, primary key
#  closed_at        :datetime
#  key              :string           not null
#  key_category     :string           not null
#  last_seen_at     :datetime         not null
#  number           :integer          not null
#  opened_at        :datetime         not null
#  production_scope :string           not null
#  subject_type     :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  account_id       :bigint           not null
#  property_id      :bigint           not null
#  subject_id       :string
#
# Indexes
#
#  existing_issue_cache_lookup                       (account_id,property_id,production_scope,closed_at)
#  existing_issue_lookup                             (account_id,property_id,key,key_category,closed_at,subject_type,subject_id)
#  index_assessment_issues_on_account_id_and_number  (account_id,number) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#  fk_rails_...  (key => assessment_descriptors.key)
#  fk_rails_...  (property_id => properties.id)
#
require "test_helper"

class Assessment::IssueTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
