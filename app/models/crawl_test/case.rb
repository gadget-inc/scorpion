# frozen_string_literal: true
# == Schema Information
#
# Table name: crawl_test_cases
#
#  id                :bigint           not null, primary key
#  error             :jsonb
#  finished_at       :datetime
#  last_html         :text
#  running           :boolean          default(FALSE), not null
#  started_at        :datetime
#  successful        :boolean
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  crawl_test_run_id :bigint           not null
#  property_id       :bigint           not null
#
# Indexes
#
#  index_crawl_test_cases_on_property_id  (property_id)
#
# Foreign Keys
#
#  fk_rails_...  (crawl_test_run_id => crawl_test_runs.id)
#

class CrawlTest::Case < ApplicationRecord
  belongs_to :crawl_test_run, class_name: "CrawlTest::Run", optional: false, foreign_key: :crawl_test_run_id, inverse_of: :crawl_test_cases
  belongs_to :property, optional: false
  has_many :logs, class_name: "CrawlTest::CaseLog", foreign_key: :crawl_test_case_id, inverse_of: :crawl_test_case, dependent: :destroy

  has_one_attached :screenshot
end
