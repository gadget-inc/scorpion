# frozen_string_literal: true
# == Schema Information
#
# Table name: crawl_test_runs
#
#  id                :bigint           not null, primary key
#  endpoint          :string           not null
#  name              :string           not null
#  property_criteria :string
#  property_limit    :integer          default(50), not null
#  running           :boolean          default(FALSE), not null
#  started_by        :string           not null
#  successful        :boolean
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class CrawlTest::Run < ApplicationRecord
  has_many :crawl_test_cases, class_name: "CrawlTest::Case", dependent: :destroy, foreign_key: :crawl_test_run_id, inverse_of: :crawl_test_run
  has_many :properties, through: :crawl_test_cases
end
