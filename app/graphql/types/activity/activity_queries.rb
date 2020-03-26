# frozen_string_literal: true
module Types::Activity
  module ActivityQueries
    extend ActiveSupport::Concern

    included do
      field :feed_items, FeedItemType.connection_type, null: false, description: "Get the feed for the current account"
    end

    def feed_items
      context[:current_account].feed_items
    end
  end
end
