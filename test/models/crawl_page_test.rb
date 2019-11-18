# frozen_string_literal: true

# == Schema Information
#
# Table name: crawl_pages
#
#  id               :bigint           not null, primary key
#  result           :jsonb            not null
#  url              :string           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  account_id       :bigint           not null
#  crawl_attempt_id :bigint           not null
#  property_id      :bigint           not null
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#  fk_rails_...  (crawl_attempt_id => crawl_attempts.id)
#  fk_rails_...  (property_id => properties.id)
#

require "test_helper"

class CrawlPageTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
