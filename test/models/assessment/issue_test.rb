# frozen_string_literal: true
# == Schema Information
#
# Table name: assessment_issues
#
#  id           :bigint           not null, primary key
#  closed_at    :datetime
#  key          :string           not null
#  key_category :string           not null
#  last_seen_at :datetime         not null
#  number       :integer          not null
#  opened_at    :datetime         not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  account_id   :bigint           not null
#  property_id  :bigint           not null
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#  fk_rails_...  (property_id => properties.id)
#
require "test_helper"

class Assessment::IssueTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
