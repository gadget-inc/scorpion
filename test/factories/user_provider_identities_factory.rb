# frozen_string_literal: true
FactoryBot.define do
  factory :user_provider_identity do
    association :user
    provider_name { "shopify" }
    provider_id { "123" }
    provider_details { {} }
  end
end
