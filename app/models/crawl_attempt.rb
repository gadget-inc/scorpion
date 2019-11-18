# frozen_string_literal: true
# == Schema Information
#
# Table name: crawl_attempts
#
#  id               :bigint           not null, primary key
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
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#  fk_rails_...  (property_id => properties.id)
#

class CrawlAttempt < ApplicationRecord
  include AccountScoped

  belongs_to :property, optional: false
end
