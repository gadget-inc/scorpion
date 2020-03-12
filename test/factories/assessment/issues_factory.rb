# frozen_string_literal: true
FactoryBot.define do
  factory :assessment_issue, class: "Assessment::Issue" do
    association :account
    association :property
    sequence(:number)
    opened_at { "2020-03-11 11:25:01" }
    last_seen_at { "2020-03-11 11:25:01" }
    key_category { "home" }
    key { "foo" }
  end
end
