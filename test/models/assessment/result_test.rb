# frozen_string_literal: true
# == Schema Information
#
# Table name: assessment_results
#
#  id            :bigint           not null, primary key
#  assessment_at :datetime         not null
#  details       :jsonb            not null
#  error_code    :string
#  key           :string           not null
#  key_category  :string           not null
#  score         :integer          not null
#  score_mode    :string           not null
#  url           :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  account_id    :bigint           not null
#  property_id   :bigint           not null
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#  fk_rails_...  (property_id => properties.id)
#
require "test_helper"

class Assessment::ResultTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
