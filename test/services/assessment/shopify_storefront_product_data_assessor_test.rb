# frozen_string_literal: true
require "test_helper"

module Assessment
  class ShopifyStorefrontProductDataAssessorTest < ActiveSupport::TestCase
    setup do
      @property = create(:ambient_homesick_property)
      @assessor = ShopifyStorefrontProductDataAssessor.new(@property)
    end

    test "it can audit products" do
      assert_difference "@property.assessment_results.size", 1380 do
        @assessor.assess_all
      end
    end
  end
end
