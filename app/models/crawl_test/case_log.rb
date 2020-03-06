# frozen_string_literal: true

# == Schema Information
#
# Table name: crawl_test_case_logs
#
#  id                 :bigint           not null, primary key
#  message            :string           not null
#  metadata           :jsonb
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  crawl_test_case_id :bigint           not null
#
# Foreign Keys
#
#  fk_rails_...  (crawl_test_case_id => crawl_test_cases.id)
#

# One remote log entry in the execution of a case
class CrawlTest::CaseLog < ApplicationRecord
  belongs_to :crawl_test_case, class_name: "CrawlTest::Case", optional: false, foreign_key: :crawl_test_case_id, inverse_of: :logs
end
