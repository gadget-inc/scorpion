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

    account_for_user = ShopifyShop.where(myshopify_domain: user_provider_identity.provider_details["shopify_domain"]).first.try(:account)
    return account_for_user if account_for_user

    creator = user_provider_identity.user
    domain = shop_auth_hash[:uid]
    token = shop_auth_hash[:credentials][:token]

    shop = ShopifyAPI::Session.temp(domain: domain, token: token, api_version: ShopifyApp.configuration.api_version) do
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

        new_property.key_urls.create!(
          account_id: new_account.id,
          creator_id: creator.id,
          url: shop_details.data.shop.primary_domain.url,
          page_type: "home",
          creation_reason: "initial",
        )

        ShopifyShop.create!(
          domain: shop_details.data.shop.primary_domain.host,
          myshopify_domain: domain,
          api_token: token,
          creator: creator,
          property: new_property,
          account: new_account,
        )
      end
    end

    # Fetch all the data for the rest of the shop columns and associated shop data in a background job
    ShopifyData::AllSyncJob.enqueue(shopify_shop_id: shop.id)

    new_account
  end
end
