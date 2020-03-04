# frozen_string_literal: true
# == Schema Information
#
# Table name: activity_feed_items
#
#  id                            :bigint           not null, primary key
#  group_end                     :datetime
#  group_start                   :datetime
#  hacky_internal_representation :jsonb
#  item_at                       :datetime         not null
#  item_type                     :string           not null
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  account_id                    :bigint           not null
#  property_id                   :bigint           not null
#
# Indexes
#
#  idx_feed_time_lookup  (account_id,property_id,item_at)
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#  fk_rails_...  (property_id => properties.id)
#
class Activity::FeedItem < ApplicationRecord
  include AccountScoped

  belongs_to :property
end
