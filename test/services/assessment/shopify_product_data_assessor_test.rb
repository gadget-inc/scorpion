# frozen_string_literal: true
require "test_helper"

class Assessment::ShopifyProductDataAssessorTest < ActiveSupport::TestCase
  setup do
    @shop = create(:shopify_shop)
    @production_group = create(:assessment_production_group, property: @shop.property)
    @assessor = Assessment::ShopifyProductDataAssessor.new(@shop, @production_group)
  end

  test "it can audit products" do
    assert_difference "@shop.property.assessment_results.size", 771 do
      @assessor.assess_all
    end
  end
end
