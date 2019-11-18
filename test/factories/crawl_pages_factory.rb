# frozen_string_literal: true
FactoryBot.define do
  factory :crawl_page do
    account_id { "" }
    property_id { "" }
    crawl_attempt_id { "" }
    url { "MyString" }
    result { "" }
  end
end
