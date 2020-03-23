# frozen_string_literal: true
FactoryBot.define do
  factory :assessment_production_group, class: "Assessment::ProductionGroup" do
    association :property
    reason { "scheduled" }
    started_at { "2020-03-23 10:14:27" }
    after(:build) do |group|
      group.account = group.property.account
    end
  end
end
