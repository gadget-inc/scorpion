# frozen_string_literal: true

class Types::Activity::FeedItemType < Types::BaseObject
  field :id, GraphQL::Types::ID, null: false
  field :item_type, String, null: false

  field :item_at, GraphQL::Types::ISO8601DateTime, null: true
  field :group_end, GraphQL::Types::ISO8601DateTime, null: false
  field :group_start, GraphQL::Types::ISO8601DateTime, null: false
  field :created_at, GraphQL::Types::ISO8601DateTime, null: false
  field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
end
