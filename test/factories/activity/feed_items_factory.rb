# frozen_string_literal: true
FactoryBot.define do
  factory :activity_feed_item, class: "Activity::FeedItem" do
    association :account
    association :property
    item_type { "TBD" }
    item_at { "2020-03-03 15:30:40" }
  end
end
