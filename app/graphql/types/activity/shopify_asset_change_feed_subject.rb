# frozen_string_literal: true

class Types::Activity::ShopifyAssetChangeFeedSubject < Types::BaseObject
  field :id, GraphQL::Types::ID, null: false
  field :action, String, null: true
  field :key, String, null: false
  field :action_at, GraphQL::Types::ISO8601DateTime, null: false
  field :created_at, GraphQL::Types::ISO8601DateTime, null: false
  field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
end
