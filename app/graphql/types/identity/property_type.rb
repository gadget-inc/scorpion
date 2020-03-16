# frozen_string_literal: true

class Types::Identity::PropertyType < Types::BaseObject
  field :id, GraphQL::Types::ID, null: false
  field :name, String, null: false
  field :enabled, Boolean, null: false

  field :crawl_roots, [String], null: false
  field :allowed_domains, [String], null: false

  field :issues, Types::Assessment::IssueType.connection_type, null: false
  field :activity_feed_items, Types::Activity::FeedItemType.connection_type, null: false

  field :creator, Types::Identity::UserType, null: false
  field :created_at, GraphQL::Types::ISO8601DateTime, null: false
  field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

  def creator
    RecordLoader.for(User).load(object.creator_id)
  end

  def issues
    AssociationLoader.for(Property, :issues).load(object)
  end
end
