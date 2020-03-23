# frozen_string_literal: true
require "test_helper"

module Assessment
  class ShopifyStorefrontProductDataAssessorTest < ActiveSupport::TestCase
    setup do
      @property = create(:ambient_homesick_property)
      @production_group = create(:assessment_production_group, property: @property)
      @assessor = ShopifyStorefrontProductDataAssessor.new(@property, @production_group)
    end

    test "it can audit products" do
      assert_difference "@property.assessment_results.size", 1380 do
        @assessor.assess_all
      end
    end
  end
end
