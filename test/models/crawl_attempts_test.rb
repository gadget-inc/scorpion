# frozen_string_literal: true
# == Schema Information
#
# Table name: crawls
#
#  id             :bigint           not null, primary key
#  finished_at    :datetime
#  running        :boolean          default(FALSE), not null
#  started_reason :string           not null
#  succeeded      :boolean
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  account_id     :bigint           not null
#  property_id    :bigint           not null
#

require "test_helper"

class CrawlAttemptsTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
