# frozen_string_literal: true

# == Schema Information
#
# Table name: property_timeline_entries
#
#  id          :bigint           not null, primary key
#  entry       :jsonb            not null
#  entry_at    :datetime         not null
#  entry_type  :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  account_id  :bigint           not null
#  property_id :bigint           not null
#

class PropertyTimelineEntry < ApplicationRecord
  include AccountScoped

  belongs_to :property

  has_one_attached :image
end
