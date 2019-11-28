# frozen_string_literal: true
# == Schema Information
#
# Table name: crawl_attempts
#
#  id               :bigint           not null, primary key
#  crawl_type       :string           default("collect_page_info")
#  failure_reason   :string
#  finished_at      :datetime
#  last_progress_at :datetime
#  running          :boolean          default(FALSE), not null
#  started_at       :datetime
#  started_reason   :string           not null
#  succeeded        :boolean
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  account_id       :bigint           not null
#  property_id      :bigint           not null
#
# Indexes
#
#  index_crawl_attempts_on_account_id_and_crawl_type_and_succeeded  (account_id,crawl_type,succeeded)
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#  fk_rails_...  (property_id => properties.id)
#

class CrawlAttempt < ApplicationRecord
  include AccountScoped

  belongs_to :property, optional: false
  enum crawl_type: { collect_page_info: "collect_page_info", collect_screenshots: "collect_screenshots" }, _prefix: :type
end
