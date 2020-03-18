# frozen_string_literal: true
require "nokogiri"

module Assessment
  # Iterates a Shopify shop's products via the storefront API to make assessments on product data quality
  # Doesn't require authentication against a shopify shop which is good for background profiling
  class ShopifyStorefrontProductDataAssessor
    include ScoreHelpers

    MINIMUM_IMAGE_COUNT = 3
    MINIMUM_IMAGE_DIMENSION = 200
    MINIMUM_PRODUCT_TITLE_LENGTH = 10
    MINIMUM_PRODUCT_DESCRIPTION_LENGTH = 400

    def initialize(property, product_limit: nil)
      @property = property
      @api = ShopifyData::StorefrontAjaxApi.new(property.crawl_roots[0])
      @product_limit = product_limit
    end

    def assess_all
      @api.all_products(limit_total: @product_limit) do |api_product|
        assess_one(api_product)
      end
    end

    def assess_one(api_product)
      @issue_governor = Assessment::IssueGovernor.new(@property, "shopify-storefront-data-product-#{api_product["id"]}")
      assess_product_images(api_product)
      assess_product_metadata(api_product)
      assess_variant_metadata(api_product)
    end

    def assess_product_images(api_product)
      make_assessment(api_product, "image-count") do |assessment|
        image_count = api_product["images"].size
        assessment.score = ratio_score(image_count.to_f / MINIMUM_IMAGE_COUNT)
        assessment.score_mode = "numeric"
        assessment.details = {
          image_count: image_count,
        }
      end

      api_product["images"].each do |image|
        make_assessment(api_product, "image-size") do |assessment|
          assessment.score = ratio_score([image["width"], image["height"]].min.to_f / MINIMUM_IMAGE_DIMENSION)
          assessment.score_mode = "numeric"
          assessment.details = {
            image_id: image["id"],
            width: image["width"],
            height: image["height"],
            src: image["src"],
          }
        end
      end
    end

    def assess_product_metadata(api_product)
      make_assessment(api_product, "product-title-length") do |assessment|
        assessment.score = ratio_score(api_product["title"].length.to_f / MINIMUM_PRODUCT_TITLE_LENGTH)
        assessment.score_mode = "binary"
        assessment.details = {
          product_id: api_product["id"],
          title_length: api_product["title"].length,
        }
      end

      make_assessment(api_product, "product-description-length") do |assessment|
        description_length = Nokogiri::HTML(api_product["body_html"]).text.length
        assessment.score = ratio_score(description_length.to_f / MINIMUM_PRODUCT_DESCRIPTION_LENGTH)
        assessment.score_mode = "numeric"
        assessment.details = {
          product_id: api_product["id"],
          description_length: description_length,
        }
      end
    end

    def assess_variant_metadata(api_product)
      make_assessment(api_product, "published-product-out-of-stock") do |assessment|
        assessment.score = if api_product["variants"].all? { |api_variant| !api_variant["available"] } then 0 else 1 end
        assessment.score_mode = "binary"
        assessment.details = {
          product_id: api_product["id"],
          variant_ids: api_product["variants"].map { |variant| variant["id"] }.sort,
        }
      end
    end

    def make_assessment(api_product, key)
      @issue_governor.make_assessment("shopify-storefront-product-data-#{key}", "products", "shopify_product", api_product["id"]) do |assessment|
        assessment.url = "#{@property.crawl_roots[0]}/products/#{api_product["handle"]}"
        yield assessment
      end
    end
  end
end
