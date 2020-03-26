# frozen_string_literal: true

class Types::Activity::FeedItemType < Types::BaseObject
  field :id, GraphQL::Types::ID, null: false
  field :item_type, String, null: false

  field :item_at, GraphQL::Types::ISO8601DateTime, null: true
  field :group_end, GraphQL::Types::ISO8601DateTime, null: false
  field :group_start, GraphQL::Types::ISO8601DateTime, null: false
  field :created_at, GraphQL::Types::ISO8601DateTime, null: false
  field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

  field :subjects, [Types::Activity::FeedItemSubjectUnion], null: false

  def subjects
    AssociationLoader.for(Activity::FeedItem, :subject_links).load(object).then do |links|
      Promise.all(links.map { |link| AssociationLoader.for(Activity::FeedItemSubjectLink, :subject).load(link) })
    end
  end
end
