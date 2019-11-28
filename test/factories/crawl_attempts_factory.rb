# frozen_string_literal: true
FactoryBot.define do
  factory :crawl_attempt do
    association :account
    association :property
    started_reason { "scheduled" }
    crawl_type { :collect_page_info }
    running { false }
  end
end
