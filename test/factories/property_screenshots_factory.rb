# frozen_string_literal: true
FactoryBot.define do
  factory :property_screenshot do
    association :account
    association :property
    association :crawl_attempt
    url { "https://google.ca" }
    result { {} }
  end
end
