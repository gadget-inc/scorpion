# frozen_string_literal: true
FactoryBot.define do
  factory :assessment_result, class: "Assessment::Result" do
    association :account
    association :property
    assessment_at { "2020-03-06 09:30:46" }
    key { "lighthouse-speed" }
    key_category { "home" }
    score { 1 }
    score_mode { "binary" }
    details { {} }
  end
end
