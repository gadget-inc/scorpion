# frozen_string_literal: true
# == Schema Information
#
# Table name: crawl_test_runs
#
#  id         :bigint           not null, primary key
#  endpoint   :string           not null
#  name       :string           not null
#  running    :boolean          default(FALSE), not null
#  started_by :string           not null
#  successful :boolean
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class CrawlTest::Run < ApplicationRecord
  has_many :crawl_test_cases, class_name: "CrawlTest::Case", dependent: :destroy
end
