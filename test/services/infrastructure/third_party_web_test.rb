# frozen_string_literal: true

require "test_helper"

class Infrastructure::ThirdPartyWebTest < ActiveSupport::TestCase
  test "it can find entities by url" do
    entity = Infrastructure::ThirdPartyWeb.instance.entity("https://cdn.shopify.com/files/1/2/test.png")
    assert_equal "Shopify", entity[:name]
  end
end
