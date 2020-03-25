# frozen_string_literal: true
FactoryBot.define do
  factory :assessment_issue, class: "Assessment::Issue" do
    association :property
    sequence(:number)
    opened_at { Time.now.utc }
    last_seen_at { Time.now.utc }
    key_category { "home" }
    key { "lighthouse-interactive" }
    production_scope { "lighthouse" }

    after(:build) do |issue|
      issue.account ||= issue.property.account
    end

    factory :assessment_issue_with_open_event do
      transient do
        assessment_production_group { nil }
      end

      after(:build) do |issue, evaluator|
        issue.issue_change_events.build(account: issue.account, property: issue.property, action: "open", action_at: issue.opened_at, production_group: evaluator.assessment_production_group)
      end
    end
  end
end
