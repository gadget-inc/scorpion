# frozen_string_literal: true

module CrawlTest
  # Runs assessments for ambient properties
  class Assessor
    def initialize(property)
      @property = property
    end

    def run_all
      run_lighthouse_crawl
      run_storefront_data_crawl
      run_interaction_crawls
    end

    def run_lighthouse_crawl
      Crawl::LighthouseCrawler.new(@property, "crawl-test").collect_lighthouse_crawl
    end

    def run_storefront_data_crawl
      Assessment::ShopifyStorefrontProductDataAssessor.new(@property).assess_all
    end

    def run_interaction_crawls
      Crawl::InteractionRunner.new(@property, "crawl-test").test_interaction("shopify-browse-add")
    end
  end
end
