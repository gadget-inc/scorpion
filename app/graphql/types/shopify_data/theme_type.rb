# frozen_string_literal: true

class Types::ShopifyData::ThemeType < Types::BaseObject
  field :id, GraphQL::Types::ID, null: false
  field :name, String, null: false
  field :role, String, null: false

  field :previewable, Boolean, null: false
  field :processing, Boolean, null: false

  field :shopify_created_at, GraphQL::Types::ISO8601DateTime, null: true
  field :shopify_updated_at, GraphQL::Types::ISO8601DateTime, null: false
  field :created_at, GraphQL::Types::ISO8601DateTime, null: false
  field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

  def previewable
    !!object.previewable
  end

  def processing
    !!object.processing
  end
end
