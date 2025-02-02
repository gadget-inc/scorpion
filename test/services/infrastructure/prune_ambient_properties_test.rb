# frozen_string_literal: true
require "test_helper"

class Infrastructure::PruneAmbientPropertiesTest < ActiveSupport::TestCase
  setup do
    create(:ambient_homesick_property)
  end

  test "it doesn't prune shopify properties" do
    assert_no_difference "Property.kept.count" do
      Infrastructure::PruneAmbientProperties.new.run
    end
  end

  test "it prunes non shopify properties" do
    create(:ambient_not_shopify_property)

    assert_difference "Property.kept.count", -1 do
      Infrastructure::PruneAmbientProperties.new.run
    end
  end
end
