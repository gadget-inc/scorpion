# frozen_string_literal: true
FactoryBot.define do
  factory :crawl_attempt, class: "Crawl::Attempt" do
    association :property
    started_reason { "scheduled" }
    crawl_type { :collect_lighthouse }
    running { false }

    after :build do |attempt|
      attempt.account = attempt.property.account
    end
  end
end
