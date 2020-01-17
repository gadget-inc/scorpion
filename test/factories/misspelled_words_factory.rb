# frozen_string_literal: true
FactoryBot.define do
  factory :misspelled_word do
    association :crawl_attempt
    word { "tiiger" }
    count { 1 }
    suggestions { %w[tiger lidar] }

    after(:build) do |word|
      word.property = word.crawl_attempt.property
      word.account = word.property.account
    end
  end
end
