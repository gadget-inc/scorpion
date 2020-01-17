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
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#  fk_rails_...  (property_id => properties.id)
#

require "test_helper"

class PropertyTimelineEntryTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
