# frozen_string_literal: true

class Types::ShopifyData::DetectedAppType < Types::BaseObject
  field :id, GraphQL::Types::ID, null: false
  field :name, String, null: false
  field :seen_last_time, Boolean, null: false
  field :reasons, [String], null: false

  field :first_seen_at, GraphQL::Types::ISO8601DateTime, null: true
  field :last_seen_at, GraphQL::Types::ISO8601DateTime, null: false
  field :created_at, GraphQL::Types::ISO8601DateTime, null: false
  field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
end
