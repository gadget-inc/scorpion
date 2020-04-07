# frozen_string_literal: true

class Types::Activity::ShopifyDetectedAppChangeFeedSubject < Types::BaseObject
  field :id, GraphQL::Types::ID, null: false
  field :action, String, null: false
  field :key, String, null: false
  field :action_at, GraphQL::Types::ISO8601DateTime, null: false
  field :created_at, GraphQL::Types::ISO8601DateTime, null: false
  field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

  field :detected_app, Types::ShopifyData::DetectedAppType, null: false

  def detected_app
    AssociationLoader.for(ShopifyData::DetectedAppChangeEvent, :detected_app).load(object)
  end
end
