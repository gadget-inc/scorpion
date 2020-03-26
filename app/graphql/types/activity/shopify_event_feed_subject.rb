# frozen_string_literal: true

class Types::Activity::ShopifyEventFeedSubject < Types::BaseObject
  field :id, GraphQL::Types::ID, null: false

  field :arguments, String, null: true
  field :author, String, null: true
  field :description, String, null: true
  field :path, String, null: true

  field :verb, String, null: false

  field :shopify_created_at, GraphQL::Types::ISO8601DateTime, null: false
  field :created_at, GraphQL::Types::ISO8601DateTime, null: false
  field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
end
