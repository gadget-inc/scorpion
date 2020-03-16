# frozen_string_literal: true

require "test_helper"

module Infrastructure
  class ThirdPartyWebTest < ActiveSupport::TestCase
    test "it can find entities by url" do
      entity = ThirdPartyWeb.instance.entity("https://cdn.shopify.com/files/1/2/test.png")
      assert_equal "Shopify", entity[:name]
    end
  end
end
