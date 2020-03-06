# frozen_string_literal: true
# == Schema Information
#
# Table name: crawl_attempts
#
#  id               :bigint           not null, primary key
#  crawl_type       :string           not null
#  failure_reason   :string
#  finished_at      :datetime
#  last_progress_at :datetime
#  running          :boolean          default("false"), not null
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
#  index_crawl_attempts_on_success_and_finished  (property_id,crawl_type,succeeded,finished_at)
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#  fk_rails_...  (property_id => properties.id)
#

module Crawl
  class Attempt < ApplicationRecord
    include AccountScoped

    belongs_to :property, optional: false
    has_many :crawl_pages, dependent: :destroy
    has_many :property_screenshots, dependent: :destroy

    enum crawl_type: { interaction: "interaction", collect_lighthouse: "collect_lighthouse" }, _prefix: :type
  end
end
