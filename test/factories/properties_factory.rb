# frozen_string_literal: true
FactoryBot.define do
  factory :property do
    association :account
    association :creator, factory: :user
    name { "Example" }
    crawl_roots { ["google.com"] }
    allowed_domains { ["google.com"] }
    enabled { true }
    ambient { false }
    internal_tags { [] }

    after(:build) do |property|
      property.key_urls << build(:key_url, property: property, account: property.account, url: property.crawl_roots[0])
    end

    factory :sole_destroyer_property do
      crawl_roots { ["https://sole-destroyer.myshopify.com"] }
      allowed_domains { ["sole-destroyer.myshopify.com"] }
    end

    factory :ambient_homesick_property do
      crawl_roots { ["https://homesick.com"] }
      allowed_domains { ["homesick.com"] }
      ambient { true }
      internal_tags { ["test_crawl"] }
      internal_test_options do
        {
          "retryStrategies": [
            {
              "name": "example retry strat",
              "config": {
                "type": "container_button",
                "selectors": {
                  "container": "#country-reveal:humanVisible",
                  "closeButton": "#country-reveal .country-close:humanVisible",
                },
              },
            },
          ],
        }
      end
    end

    factory :ambient_failure_property do
      crawl_roots { ["https://bape.com"] }
      allowed_domains { ["bape.com"] }
      ambient { true }
      internal_tags { ["test_crawl"] }
    end

    factory :doesnt_exist_property do
      crawl_roots { ["https://this-domain-doesnt-exist.kdjflksj3333flskj.com"] }
      allowed_domains { ["this-domain-doesnt-exist.kdjflksj3333flskj.com"] }
    end
  end
end
