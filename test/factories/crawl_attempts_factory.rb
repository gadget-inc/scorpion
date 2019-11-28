# frozen_string_literal: true
FactoryBot.define do
  factory :crawl_attempt do
    association :property
    started_reason { "scheduled" }
    crawl_type { :collect_page_info }
    running { false }

    after :build do |attempt|
      attempt.account = attempt.property.account
    end
  end
end
