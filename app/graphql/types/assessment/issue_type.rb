# frozen_string_literal: true

class Types::Assessment::IssueType < Types::BaseObject
  field :id, GraphQL::Types::ID, null: false
  field :key, String, null: false
  field :key_category, Types::Assessment::KeyCategory, null: false
  field :name, String, null: false
  field :name_with_title, String, null: false
  field :number, Int, null: false

  field :closed_at, GraphQL::Types::ISO8601DateTime, null: true
  field :opened_at, GraphQL::Types::ISO8601DateTime, null: false
  field :last_seen_at, GraphQL::Types::ISO8601DateTime, null: false
  field :created_at, GraphQL::Types::ISO8601DateTime, null: false
  field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

  field :results, Types::Assessment::ResultType.connection_type, null: false
  field :descriptor, Types::Assessment::DescriptorType, null: false

  field :subject_type, Types::Assessment::IssueTypeEnum, null: true
  field :subject_id, String, null: true

  def name
    "Issue ##{object.number}"
  end

  def name_with_title
    descriptor.then { |desc| "#{name} - #{desc.title}" }
  end

  def descriptor
    AssociationLoader.for(Assessment::Issue, :descriptor).load(object)
  end
end
