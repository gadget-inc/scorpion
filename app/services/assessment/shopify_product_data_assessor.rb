# frozen_string_literal: true
require "nokogiri"

module Assessment
  # Iterates a Shopify shop's products via the API to make assessments
  class ShopifyProductDataAssessor
    include ShopifyData::ShopifyApiRetries

    MINIMUM_IMAGE_COUNT = 3
    MINIMUM_IMAGE_DIMENSION = 200
    MINIMUM_PRODUCT_TITLE_LENGTH = 10
    MINIMUM_PRODUCT_DESCRIPTION_LENGTH = 400

    def initialize(shop, reason)
      @shop = shop
      @reason = reason  # TODO: something with this. this isn't a crawl attempt persay but maybe assessments should know why they were made?
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
      if api_product.images.size < MINIMUM_IMAGE_COUNT
        assessment = base_assessment_record(api_product, "image-count")
        assessment.score = (api_product.images.size.to_f / MINIMUM_IMAGE_COUNT * 100).round
        assessment.score_mode = "numeric"
        assessment.details = {
          image_count: api_product.images.size,
        }
        assessment.save!
      end

      api_product.images.each do |image|
        if image.width < MINIMUM_IMAGE_DIMENSION || image.height < MINIMUM_IMAGE_DIMENSION
          assessment = base_assessment_record(api_product, "image-size")
          assessment.score = ([image.width, image.height].min / MINIMUM_IMAGE_DIMENSION * 100).round
          assessment.score_mode = "numeric"
          assessment.details = {
            image_id: image.id,
            width: image.width,
            height: image.height,
            src: image.src,
          }
          assessment.save!
        end
      end
    end

    def assess_product_metadata(api_product)
      if api_product.title.length < MINIMUM_PRODUCT_TITLE_LENGTH
        assessment = base_assessment_record(api_product, "product-title-length")
        assessment.score = ((api_product.title.length.to_f / MINIMUM_PRODUCT_TITLE_LENGTH) * 100).round
        assessment.score_mode = "binary"
        assessment.details = {
          product_id: api_product.id,
          title_length: api_product.title.length,
        }
        assessment.save!
      end

      description_length = Nokogiri::HTML(api_product.body_html).text.length
      if description_length < MINIMUM_PRODUCT_DESCRIPTION_LENGTH
        assessment = base_assessment_record(api_product, "product-description-length")
        assessment.score = ((description_length.to_f / MINIMUM_PRODUCT_DESCRIPTION_LENGTH) * 100).round
        assessment.score_mode = "numeric"
        assessment.details = {
          product_id: api_product.id,
          description_length: description_length,
        }
        assessment.save!
      end
    end

    def assess_variant_metadata(api_product)
      if api_product.published_at.present?
        # Check if all variants are out of stock
        tracked_variants = api_product.variants.select { |api_variant| api_variant.inventory_policy == "deny" }
        if tracked_variants.all? { |api_variant| api_variant.inventory_quantity <= 0 }
          assessment = base_assessment_record(api_product, "product-out-of-stock")
          assessment.score = 0
          assessment.score_mode = "binary"
          assessment.details = {
            product_id: api_product.id,
            variant_ids: tracked_variants.map(&:id),
          }
          assessment.save!
        end
      end
    end

    def base_assessment_record(api_product, key)
      @property.assessment_results.build(
        account_id: @property.account_id,
        key: "shopify-product-data-#{key}",
        key_category: "products",
        assessment_at: Time.now.utc,
        url: "https://#{@shop.domain}/products/#{api_product.handle}",
      )
    end
  end
end
