# frozen_string_literal: true
FactoryBot.define do
  factory :key_url do
    association :account
    association :property
    url { "https://test.com" }
    page_type { "home" }
    creation_reason { "initial" }
  end
end
