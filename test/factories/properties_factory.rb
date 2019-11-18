# frozen_string_literal: true
FactoryBot.define do
  factory :property do
    association :account
    association :creator, factory: :user
    name { "Example" }
    crawl_roots { ["google.com"] }
    allowed_domains { ["google.com"] }

    factory :sole_destroyer_property do
      crawl_roots { ["https://sole-destroyer.myshopify.com"] }
      allowed_domains { ["sole-destroyer.myshopify.com"] }
    end
  end
end
