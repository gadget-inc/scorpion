# frozen_string_literal: true
require "test_helper"

class Assessment::ShopifyStorefrontProductDataAssessorTest < ActiveSupport::TestCase
  test "it can audit products" do
    @property = create(:ambient_homesick_property)
    @assessor = assessor_for_property(@property)
    assert_difference "@property.assessment_results.size", 781 do
      @assessor.assess_all
    end
  end

  test "it doesn't raise if there is an error connecting to the storefront" do
    @property = create(:doesnt_exist_property)
    @assessor = assessor_for_property(@property)

    assert_nothing_raised do
      assert_difference "@property.assessment_results.size", 0 do
        @assessor.assess_all
      end
    end
  end

  def assessor_for_property(property)
    production_group = create(:assessment_production_group, property: property)
    Assessment::ShopifyStorefrontProductDataAssessor.new(property, production_group, product_limit: 10)
  end
end
