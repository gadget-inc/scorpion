# frozen_string_literal: true
FactoryBot.define do
  factory :assessment_issue_change_event, class: "Assessment::IssueChangeEvent" do
    association :property
    action { "open" }
    action_at { "2020-03-23 10:13:14" }

    after(:build) do |event|
      event.account = event.property.account
      event.issue ||= build(:assessment_issue, property: event.property, account: event.property.account)
    end
  end
end
