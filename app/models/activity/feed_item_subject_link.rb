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
class Activity::FeedItemSubjectLink < ApplicationRecord
  include AccountScoped

  belongs_to :feed_item, class_name: "Activity::FeedItem", foreign_key: :activity_feed_item_id, inverse_of: :subject_links
  belongs_to :subject, polymorphic: true
end
