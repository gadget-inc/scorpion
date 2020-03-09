# frozen_string_literal: true
require "test_helper"

module Assessment
  class ShopifyProductDataAssessorTest < ActiveSupport::TestCase
    setup do
      @shop = create(:shopify_shop)
      @assessor = ShopifyProductDataAssessor.new(@shop, "test")
    end

    test "it can audit products" do
      assert_difference "@shop.property.assessment_results.size", 69 do
        @assessor.assess_all
      end
    end
  end
end
