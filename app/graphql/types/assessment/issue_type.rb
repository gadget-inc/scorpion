# frozen_string_literal: true

class Types::Assessment::IssueType < Types::BaseObject
  field :id, GraphQL::Types::ID, null: false
  field :key, String, null: false
  field :key_category, Types::Assessment::KeyCategory, null: false
  field :name, String, null: false
  field :number, Int, null: false

  field :closed_at, GraphQL::Types::ISO8601DateTime, null: true
  field :opened_at, GraphQL::Types::ISO8601DateTime, null: false
  field :last_seen_at, GraphQL::Types::ISO8601DateTime, null: false
  field :created_at, GraphQL::Types::ISO8601DateTime, null: false
  field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

  field :results, Types::Assessment::ResultType.connection_type, null: false

  def name
    "Issue ##{object.number}"
  end
end
