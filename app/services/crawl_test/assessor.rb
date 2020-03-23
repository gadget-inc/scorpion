# frozen_string_literal: true

module CrawlTest
  # Runs assessments for ambient properties
  class Assessor
    attr_reader :property, :production_group

    def initialize(property, production_group)
      @property = property
      @production_group = production_group
    end

    def run_all
      run_lighthouse_crawl
      run_storefront_data_crawl
      run_interaction_crawls
    end

    def run_lighthouse_crawl
      Crawl::LighthouseCrawler.new(@property, @production_group).collect_lighthouse_crawl
    end

    def run_storefront_data_crawl
      Assessment::ShopifyStorefrontProductDataAssessor.new(@property, @production_group, product_limit: 50).assess_all
    end

    def run_interaction_crawls
      Crawl::InteractionRunner.new(@property, @production_group).test_interaction("shopify-browse-add")
    end
  end
end
