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

    transient do
      create_shopify_shop { false }
    end

    after(:build) do |property, evaluator|
      property.key_urls << build(:key_url, property: property, account: property.account, url: property.crawl_roots[0])

      if evaluator.create_shopify_shop && !property.shopify_shop
        property.shopify_shop = build(:shopify_shop, account: property.account, property: property, domain: property.crawl_roots[0], myshopify_domain: property.crawl_roots[0])
      end
    end

    # factory for use in tests that are VCRing against a real store. Dynamically produces the factory based on the developer's environment, or, the default ENV vars set in the test_helper.
    factory :live_test_myshopify_property do
      crawl_roots { ["https://#{ENV["SHOPIFY_SHOP_OAUTH_DOMAIN"]}"] }
      allowed_domains { [ENV["SHOPIFY_SHOP_OAUTH_DOMAIN"]] }
      create_shopify_shop { true }
    end

    factory :harry_test_charlie_property do
      crawl_roots { ["https://harry-test-charlie.myshopify.com"] }
      allowed_domains { ["harry-test-charlie.myshopify.com"] }
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

    factory :ambient_not_shopify_property do
      crawl_roots { ["https://example.com"] }
      allowed_domains { ["example.com"] }
      ambient { true }
    end
  end
end
