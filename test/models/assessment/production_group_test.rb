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
require "test_helper"

class Assessment::ProductionGroupTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
