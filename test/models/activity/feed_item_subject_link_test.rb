# frozen_string_literal: true

# == Schema Information
#
# Table name: activity_feed_item_subject_links
#
#  id                    :bigint           not null, primary key
#  subject_type          :string           not null
#  account_id            :bigint           not null
#  activity_feed_item_id :bigint           not null
#  subject_id            :bigint           not null
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#  fk_rails_...  (activity_feed_item_id => activity_feed_items.id)
#
require "test_helper"

class Activity::FeedItemSubjectLinkTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
