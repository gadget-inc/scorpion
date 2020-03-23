# frozen_string_literal: true
require "nokogiri"

module Assessment
  # Iterates a Shopify shop's products via the API to make assessments
  class ShopifyProductDataAssessor
    include ShopifyData::ShopifyApiRetries
    include ScoreHelpers

    MINIMUM_IMAGE_COUNT = 3
    MINIMUM_IMAGE_DIMENSION = 200
    MINIMUM_PRODUCT_TITLE_LENGTH = 10
    MINIMUM_PRODUCT_DESCRIPTION_LENGTH = 400

    def initialize(shop, production_group)
      @shop = shop
      @production_group = production_group
      @property = shop.property
    end

    def assess_all
      @shop.with_shopify_session do
        paginated_products do |page|
          page.each do |api_product|
            assess_one(api_product)
          end
        end
      end
    end

    def assess_one(api_product)
      @issue_governor = Assessment::IssueGovernor.new(@property, @production_group, "shopify-data-product-#{api_product.id}")
      assess_product_images(api_product)
      assess_product_metadata(api_product)
      assess_variant_metadata(api_product)
    end

    def paginated_products
      products = with_retries { ShopifyAPI::Product.find(:all, params: { limit: 250, published_status: "published" }) }
      yield products
      while products.next_page?
        products = with_retries { products.fetch_next_page }
        yield products
      end
    end

    def assess_product_images(api_product)
      make_assessment(api_product, "image-count") do |assessment|
        assessment.score = ratio_score(api_product.images.size.to_f / MINIMUM_IMAGE_COUNT)
        assessment.score_mode = "numeric"
        assessment.details = {
          image_count: api_product.images.size,
        }
      end

      api_product.images.each do |image|
        make_assessment(api_product, "image-size") do |assessment|
          assessment.score = ratio_score([image.width, image.height].min.to_f / MINIMUM_IMAGE_DIMENSION)
          assessment.score_mode = "numeric"
          assessment.details = {
            image_id: image.id,
            width: image.width,
            height: image.height,
            src: image.src,
          }
        end
      end
    end

    def assess_product_metadata(api_product)
      make_assessment(api_product, "product-title-length") do |assessment|
        assessment.score = ratio_score(api_product.title.length.to_f / MINIMUM_PRODUCT_TITLE_LENGTH)
        assessment.score_mode = "binary"
        assessment.details = {
          product_id: api_product.id,
          title_length: api_product.title.length,
        }
      end

      make_assessment(api_product, "product-description-length") do |assessment|
        description_length = Nokogiri::HTML(api_product.body_html).text.length
        assessment.score = ratio_score(description_length.to_f / MINIMUM_PRODUCT_DESCRIPTION_LENGTH)
        assessment.score_mode = "numeric"
        assessment.details = {
          product_id: api_product.id,
          description_length: description_length,
        }
      end
    end

    def assess_variant_metadata(api_product)
      make_assessment(api_product, "published-product-out-of-stock") do |assessment|
        tracked_variants = api_product.variants.select { |api_variant| api_variant.inventory_policy == "deny" }
        assessment.score = if tracked_variants.all? { |api_variant| api_variant.inventory_quantity <= 0 } then 0 else 1 end
        assessment.score_mode = "binary"
        assessment.details = {
          product_id: api_product.id,
          variant_ids: tracked_variants.map(&:id).sort,
        }
      end
    end

    def make_assessment(api_product, key)
      @issue_governor.make_assessment("shopify-product-data-#{key}", "products", "shopify_product", api_product.id.to_s) do |assessment|
        assessment.url = "https://#{@shop.domain}/products/#{api_product.handle}"
        yield assessment
      end
    end
  end
end
