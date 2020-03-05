# frozen_string_literal: true

require "test_helper"

class Identity::ShopifySignUpTest < ActiveSupport::TestCase
  setup do
    @user = create(:user)
    @provider_identity = create(:user_provider_identity, user: @user)
    @creator = Identity::ShopifySignUp.new
  end

  test "it creates an account, property, and shop" do
    assert_difference "Account.count", 1 do
      assert_difference "Property.count", 1 do
        assert_difference "ShopifyShop.count", 1 do
          account = @creator.create_account_if_necessary!(@provider_identity, {
            :provider => "shopify",
            :uid => ENV["SHOPIFY_SHOP_OAUTH_DOMAIN"],
            :credentials => {
              :token => ENV["SHOPIFY_SHOP_OAUTH_ACCESS_TOKEN"],
            },
          })

          assert account.name.present?
          assert_equal @user, account.creator
          assert_includes @user.reload.permissioned_accounts, account

          assert property = account.properties.first
          assert_operator 0, :<, property.allowed_domains.size
          assert_operator 0, :<, property.crawl_roots.size
          assert_equal @user, property.creator

          assert root_key_url = property.key_urls.first
          assert_not_nil root_key_url.url
          assert_not_nil root_key_url.creation_reason

          assert shop = ShopifyShop.where(property_id: property.id).first
          assert_equal ENV["SHOPIFY_SHOP_OAUTH_DOMAIN"], shop.domain
          assert_equal ENV["SHOPIFY_SHOP_OAUTH_ACCESS_TOKEN"], shop.api_token
          assert_equal @user, shop.creator
          assert_equal property, shop.property
          assert_equal account, shop.account
        end
      end
    end
  end
end
