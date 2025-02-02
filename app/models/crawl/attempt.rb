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

module Crawl
  # Represents the infrastructure concerns around making a batch of assessments. A successful crawl is one where nothing we have responsibility for broke, which means a crawl can succeed and produce a lot of assessments / errors. A failure is when our infrastructure gets in the way of making assessments.
  class Attempt < ApplicationRecord
    include AccountScoped

    belongs_to :property, optional: false

    enum crawl_type: { interaction: "interaction", collect_lighthouse: "collect_lighthouse" }, _prefix: :type
  end
end
