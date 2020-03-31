# frozen_string_literal: true

class Types::Assessment::IssueTypeEnum < Types::BaseEnum
  value "URL", value: "url", description: "A web URL an issue was discovered on"
  value "SHOPIFY_PRODUCT", value: "shopify_product", description: "A Shopify product ID an issue was discovered on"
end
