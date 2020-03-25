# frozen_string_literal: true
FactoryBot.define do
  factory :key_url do
    association :property
    url { "https://test.com" }
    page_type { "home" }
    creation_reason { "initial" }

    after(:build) do |key_url|
      key_url.account ||= key_url.property.account
    end
  end
end
