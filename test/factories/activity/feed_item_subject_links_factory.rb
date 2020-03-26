# frozen_string_literal: true
FactoryBot.define do
  factory :activity_feed_item_subject_link, class: "Activity::FeedItemSubjectLink" do
    association :activity_feed_item

    after(:build) do |link|
      link.account = link.activity_feed_item.account
      link.subject ||= build(:assessment_production_group, account: link.account, property: link.account.properties.first)
    end
  end
end
