# frozen_string_literal: true

class Identity::ShopifySignUp
  SHOP_DETAILS_QUERY = ShopifyAPI::GraphQL.client.parse <<-GRAPHQL
  {
    shop {
      name
      myshopifyDomain
      primaryDomain {
        host
        url
      }
    }
  }
GRAPHQL

  def create_account_if_necessary!(user_provider_identity, shop_auth_hash)
    new_account = nil

    account_for_user = ShopifyShop.where(domain: user_provider_identity.provider_details["shopify_domain"]).first.try(:account)
    return account_for_user if account_for_user

    creator = user_provider_identity.user
    domain = shop_auth_hash[:uid]
    token = shop_auth_hash[:credentials][:token]

    ShopifyAPI::Session.temp(domain: domain, token: token, api_version: ShopifyApp.configuration.api_version) do
      shop_details = ShopifyAPI::GraphQL.client.query(SHOP_DETAILS_QUERY)

      Account.transaction do
        new_account = Identity::CreateAccount.new(creator).create!({ name: shop_details.data.shop.name })
        new_property = Property.create!(
          allowed_domains: [shop_details.data.shop.myshopify_domain, shop_details.data.shop.primary_domain.host].uniq,
          crawl_roots: [shop_details.data.shop.primary_domain.url],
          name: shop_details.data.shop.name,
          creator: creator,
          account: new_account,
          ambient: false,
          enabled: true,
        )

        ShopifyShop.create!(
          domain: domain,
          api_token: token,
          creator: creator,
          property: new_property,
          account: new_account,
        )
      end
    end

    new_account
  end
end
