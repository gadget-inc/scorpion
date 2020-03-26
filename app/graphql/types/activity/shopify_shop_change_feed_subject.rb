# frozen_string_literal: true

class Types::Activity::ShopifyShopChangeFeedSubject < Types::BaseObject
  field :id, GraphQL::Types::ID, null: false

  field :old_value, Types::JSONScalar, null: true
  field :new_value, Types::JSONScalar, null: true
  field :record_attribute, String, null: false

  field :created_at, GraphQL::Types::ISO8601DateTime, null: false
  field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
end
