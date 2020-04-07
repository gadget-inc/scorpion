# frozen_string_literal: true

class Types::Activity::ShopifyAssetChangeFeedSubject < Types::BaseObject
  field :id, GraphQL::Types::ID, null: false
  field :key, String, null: false
  field :action, String, null: false
  field :action_at, GraphQL::Types::ISO8601DateTime, null: false

  field :created_at, GraphQL::Types::ISO8601DateTime, null: false
  field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

  field :theme, Types::ShopifyData::ThemeType, null: false

  def theme
    AssociationLoader.for(ShopifyData::AssetChangeEvent, :theme).load(object)
  end
end
