# frozen_string_literal: true
FactoryBot.define do
  factory :activity_feed_item, class: "Activity::FeedItem" do
    association :property
    item_type { "event" }
    item_at { "2020-03-03 15:30:40" }
    group_start { "2020-03-03 15:30:40" }
    group_end { "2020-03-03 15:30:40" }

    after(:build) do |item|
      item.account ||= item.property.account
    end
  end
end
