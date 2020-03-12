# frozen_string_literal: true

class Types::Assessment::ResultType < Types::BaseObject
  field :id, GraphQL::Types::ID, null: false
  field :key, String, null: false
  field :key_category, Types::Assessment::KeyCategory, null: false

  field :score, Int, null: false
  field :score_mode, String, null: false

  field :url, String, null: true
  field :details, Types::JSONScalar, null: false

  field :assessment_at, GraphQL::Types::ISO8601DateTime, null: false
  field :created_at, GraphQL::Types::ISO8601DateTime, null: false
  field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

  field :issue, Types::Assessment::IssueType, null: true

  def issue
    AssociationLoader.for(::Assessment::Result, :issue).load(object)
  end
end
