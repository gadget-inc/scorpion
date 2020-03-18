# frozen_string_literal: true

module ShopifyData
  # Wrapper for the Shopify AJAX storefront API, https://shopify.dev/docs/ajax-api/reference
  # Note: not for the authenticated GraphQL API called the "Storefront API", this is for the unauthenticated one that sucks more
  class StorefrontAjaxApi
    def initialize(base_url)
      @base_url = base_url
    end

    def all_products(limit_total: nil)
      page = 1 # shopify api starts at 1 indexing for pages
      limit = 100
      total = 0
      handles = Set.new

      loop do
        result = products(page: page, limit: limit, order: "id")
        result.each do |product|
          if handles.include?(product["handle"])
            raise "Duplicate product returned from pagination"
          else
            handles.add(product["handle"])
          end
          total += 1
          yield product
        end

        if result.size < limit
          break
        end

        if limit_total && total >= limit_total
          break
        end

        page += 1
      end
    end

    def products(page: nil, limit: nil, order: nil)
      request("/products.json", { page: page, limit: limit, order: order })["products"]
    end

    def request(path, params)
      response = RestClient::Request.execute(
        method: :get,
        url: @base_url + path,
        open_timeout: 5,
        timeout: 60,
        headers: {
          params: params,
        },
        accept: :json,
      )

      JSON.parse(response.body)
    end
  end
end
