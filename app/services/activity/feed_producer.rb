# frozen_string_literal: true
module Activity
  # A feed that looks at a bunch of event sources and tries to group them a little bit in time into feed items that make some sense to humans. A bunch of events of a similar nature happening in quick succession should be grouped into one item, but events happening at different times likely triggered by different people or processes should be independent items.
  class FeedProducer
    include SemanticLogger::Loggable

    EPOCH = Time.utc(2000)

    EVENT_SOURCES = {
      ShopifyData::Event => { cursor: :created_at },
      ShopifyData::ShopChangeEvent => { cursor: :created_at },
      ShopifyData::AssetChangeEvent => { scope: ShopifyData::AssetChangeEvent.includes(:theme), cursor: :action_at },
      ShopifyData::ThemeChangeEvent => { scope: ShopifyData::ThemeChangeEvent.includes(:theme), cursor: :created_at },
      ShopifyData::DetectedAppChangeEvent => { scope: ShopifyData::DetectedAppChangeEvent.includes(:detected_app), cursor: :created_at },
    }.freeze

    def initialize(property)
      @property = property
      @account = property.account
      @shop = ShopifyShop.kept.find_by!(property_id: @property.id)
    end

    def produce
      most_recent_item = @property.activity_feed_items.order("group_end DESC").first
      high_watermark = most_recent_item.try(:group_end) || EPOCH

      existing_group_events = []
      new_group_events = []

      new_events = EVENT_SOURCES.flat_map do |(klass, _)|
        new_events_for_source(klass, high_watermark)
      end

      new_for_existing, new_for_new = find_group_threshold_and_split(new_events, most_recent_item)
      existing_group_events << new_for_existing
      new_group_events << new_for_new

      ActiveRecord::Base.transaction do
        save_item!(most_recent_item, existing_group_events.flatten) if most_recent_item.present?
        save_item!(FeedItem.new(account_id: @account.id, property_id: @property.id), new_group_events.flatten)
      end
    end

    def save_item!(item, events)
      if !events.empty?
        cursors = events.map { |event| cursor_value(event) }
        max = cursors.max
        item.group_start = cursors.min
        item.group_end = max
        item.item_at = max

        item.item_type = if events.size > 1
            "event_group"
          else
            "event"
          end

        item.hacky_internal_representation ||= { "events" => [] }
        item.hacky_internal_representation["events"] += events.map { |event| hacky_internal_event_representation(event) }

        item.save!
      end
    end

    def new_events_for_source(source_class, high_watermark)
      descriptor = EVENT_SOURCES.fetch(source_class)
      cursor_property = descriptor.fetch(:cursor)
      scope = descriptor[:scope] || source_class
      scope = scope.where(account_id: @account.id, shopify_shop_id: @shop.id).order({ cursor_property => :asc })
      scope = scope.where(":property > :high_watermark", property: cursor_property, high_watermark: high_watermark)
      records = scope.to_a.filter { |event| event[cursor_property] > high_watermark } # wtf
      logger.info "Retrieved records for feed", klass: source_class.name, size: records.size
      records
    end

    def find_group_threshold_and_split(new_events, most_recent_item)
      group_start = if most_recent_item
          most_recent_item.group_start
        else
          EPOCH
        end

      # Groups should be a maximum of 8 minutes long. This will probably get fancier.
      threshold = group_start + 8.minutes
      events_for_existing, events_for_new = new_events.partition { |event| cursor_value(event) <= threshold }
      [events_for_existing, events_for_new]
    end

    def hacky_internal_event_representation(event)
      case event
      when ShopifyData::Event
        event.description
      when ShopifyData::AssetChangeEvent
        "Theme #{event.theme.name} asset #{event.key} #{event.action} action"
      when ShopifyData::ShopChangeEvent
        "Shop #{event.record_attribute} #{event.old_value} => #{event.new_value}"
      when ShopifyData::ThemeChangeEvent
        "Theme #{event.theme.name} #{event.record_attribute} #{event.old_value} => #{event.new_value}"
      when ShopifyData::DetectedAppChangeEvent
        "App #{event.detected_app.name} #{event.action} action"
      else
        raise "Unknown event class for representing #{event.class}"
      end
    end

    def cursor_value(event)
      property = EVENT_SOURCES.fetch(event.class).fetch(:cursor)
      event[property]
    end
  end
end
