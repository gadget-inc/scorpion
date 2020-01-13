# frozen_string_literal: true
FactoryBot.define do
  factory :property_timeline_entry do
    association :account
    association :property
    entry_at { "2020-01-13 11:22:15" }
    entry_type { "screenshot" }
    entry { {} }
  end
end
