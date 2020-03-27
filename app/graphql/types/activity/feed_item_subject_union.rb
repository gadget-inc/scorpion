# frozen_string_literal: true
class Types::Activity::FeedItemSubjectUnion < Types::BaseUnion
  description "Objects which may be one of the subjects of a FeedItem"
  possible_types Types::Activity::ShopifyEventFeedSubject, Types::Activity::ShopifyShopChangeFeedSubject, Types::Activity::ShopifyAssetChangeFeedSubject, Types::Activity::ShopifyThemeChangeFeedSubject, Types::Activity::ShopifyDetectedAppChangeFeedSubject, Types::Assessment::ProductionGroupType, Types::Assessment::IssueChangeEventType

  def self.resolve_type(object, _context)
    case object
    when ShopifyData::Event then Types::Activity::ShopifyEventFeedSubject
    when ShopifyData::ShopChangeEvent then Types::Activity::ShopifyShopChangeFeedSubject
    when ShopifyData::AssetChangeEvent then Types::Activity::ShopifyAssetChangeFeedSubject
    when ShopifyData::ThemeChangeEvent then Types::Activity::ShopifyThemeChangeFeedSubject
    when ShopifyData::DetectedAppChangeEvent then Types::Activity::ShopifyDetectedAppChangeFeedSubject
    when Assessment::ProductionGroup then Types::Assessment::ProductionGroupType
    when Assessment::IssueChangeEvent then Types::Assessment::IssueChangeEventType
    else raise "Unknown type of feed item: #{object.class.name}"
    end
  end
end
