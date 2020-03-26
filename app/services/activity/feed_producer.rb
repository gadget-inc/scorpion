# frozen_string_literal: true
module Activity
  # A feed that looks at a bunch of event sources and tries to group them a little bit in time into feed items that make some sense to humans. A bunch of events of a similar nature happening in quick succession should be grouped into one item, but events happening at different times likely triggered by different people or processes should be independent items.
  class FeedProducer
    include SemanticLogger::Loggable

    EPOCH = Time.utc(2000)

    EVENT_SOURCES = {
      ShopifyData::Event => {
        cursor: :created_at,
        filter_on: [:shopify_shop_id],
        item_type: :shop_changes,
      },
      ShopifyData::ShopChangeEvent => {
        cursor: :created_at,
        filter_on: [:shopify_shop_id],
        item_type: :shop_changes,
      },
      ShopifyData::AssetChangeEvent => {
        scope: ShopifyData::AssetChangeEvent.includes(:theme),
        cursor: :action_at,
        filter_on: [:shopify_shop_id],
        item_type: :shop_changes,
      },
      ShopifyData::ThemeChangeEvent => {
        scope: ShopifyData::ThemeChangeEvent.includes(:theme),
        cursor: :created_at,
        filter_on: [:shopify_shop_id],
        item_type: :shop_changes,
      },
      ShopifyData::DetectedAppChangeEvent => {
        scope: ShopifyData::DetectedAppChangeEvent.includes(:detected_app),
        cursor: :created_at,
        filter_on: [:shopify_shop_id],
        item_type: :app_changes,
      },
      Assessment::IssueChangeEvent => {
        scope: Assessment::IssueChangeEvent.manual.includes(:issue),
        cursor: :action_at,
        filter_on: [:property_id],
        item_type: :manual_issue_changes,
      },
      Assessment::ProductionGroup => {
        scope: Assessment::ProductionGroup.includes(:issue_change_events),
        cursor: :created_at,
        filter_on: [:property_id],
        item_type: :scan,
        allow_grouping: false,
      },
    }.freeze

    def initialize(property)
      @property = property
      @account = property.account
      @shop = @property.shopify_shop
      raise "Can't currently build feeds for properties without shopify shops" if @shop.nil?
    end

    def produce
      most_recent_item = @property.activity_feed_items.order("group_end DESC").first
      high_watermark = most_recent_item.try(:group_end) || EPOCH

      new_events = EVENT_SOURCES.flat_map do |(klass, _)|
        new_events_for_source(klass, high_watermark)
      end
      new_events.sort_by! { |event| cursor_value(event) }

      items = group_events_into_items(most_recent_item, new_events)

      Activity::FeedItem.transaction do
        items.each(&:save!)
      end
    end

    def group_events_into_items(most_recent_feed_item, sorted_events)
      current_feed_item = most_recent_feed_item
      items = []
      current_group_buffer = []

      sorted_events.each do |event|
        if current_feed_item && can_group?(current_feed_item, event)
          # This item can be added to the current group, stick it in the buffer
          current_group_buffer << event
        else
          # This group is over, finalize the feed item and reset the current buffer and item for the next group
          if current_feed_item && !current_group_buffer.empty?
            items << finalize_item(current_feed_item, current_group_buffer)
          end

          current_group_buffer = [event]
          current_feed_item = Activity::FeedItem.new(
            account_id: @account.id,
            property_id: @property.id,
            item_type: item_type(event),
            group_start: cursor_value(event),
          )
        end
      end

      if current_feed_item && !current_group_buffer.empty?
        items << finalize_item(current_feed_item, current_group_buffer)
      end

      items
    end

    def finalize_item(item, events)
      if events.empty?
        raise "Can't create a feed item with no events"
      end
      cursors = events.map { |event| cursor_value(event) }
      max = cursors.max
      item.group_start = cursors.min
      item.group_end = max
      item.item_at = max
      events.each do |event|
        item.subject_links.build(account_id: @property.account_id, subject: event)
      end
      item
    end

    def new_events_for_source(source_class, high_watermark)
      descriptor = EVENT_SOURCES.fetch(source_class)
      cursor_column = descriptor.fetch(:cursor)
      scope = descriptor[:scope] || source_class.all

      descriptor.fetch(:filter_on).each do |filter_column|
        case filter_column
        when :shopify_shop_id then scope = scope.where(shopify_shop_id: @shop.id)
        when :property_id then scope = scope.where(property_id: @property.id)
        else raise "Unknown feed producer filter column #{filter_column}"
        end
      end

      scope = scope.where(account_id: @account.id)
      scope = scope.order({ cursor_column => :asc })
      scope = scope.where(":cursor_column > :high_watermark", cursor_column: cursor_column, high_watermark: high_watermark)
      records = scope.to_a.filter { |event| event[cursor_column] > high_watermark } # wtf
      logger.info "Retrieved records for feed", klass: source_class.name, size: records.size
      records
    end

    def can_group?(feed_item, event)
      descriptor = EVENT_SOURCES.fetch(event.class)
      threshold = feed_item.group_start + 8.minutes
      feed_item.item_type == descriptor.fetch(:item_type).to_s && descriptor[:allow_grouping] != false && cursor_value(event) <= threshold
    end

    def cursor_value(event)
      property = EVENT_SOURCES.fetch(event.class).fetch(:cursor)
      event[property]
    end

    def item_type(event)
      EVENT_SOURCES.fetch(event.class).fetch(:item_type)
    end
  end
end
