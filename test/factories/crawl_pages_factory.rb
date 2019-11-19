# frozen_string_literal: true
FactoryBot.define do
  factory :crawl_page do
    association :account
    association :property
    association :crawl_attempt
    url { "http://google.ca" }
    result { {} }
  end
end
