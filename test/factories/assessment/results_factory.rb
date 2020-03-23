# frozen_string_literal: true
FactoryBot.define do
  factory :assessment_result, class: "Assessment::Result" do
    association :property
    assessment_at { "2020-03-06 09:30:46" }
    key { "lighthouse-speed" }
    key_category { "home" }
    production_scope { "lighthouse" }
    score { 1 }
    score_mode { "binary" }
    details { {} }

    after(:build) do |result|
      result.account = result.property.account
      result.production_group = build(:assessment_production_group, account: result.property.account, property: result.property)
    end
  end
end
