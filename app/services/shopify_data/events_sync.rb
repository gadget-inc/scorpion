# frozen_string_literal: true
module ShopifyData
  # Knows how to fetch all the new Shopify events since the last time it ran and save them to the database
  class EventsSync
    include ShopifyApiRetries
    include Wisper::Publisher
    attr_reader :shop

    def initialize(shop, params = {})
      @shop = shop
      @account = shop.account
      @now = Time.now.utc
      @params = { limit: 250 }.merge(params)
    end

    def run
      @shop.with_shopify_session do
        events = with_retries { ShopifyAPI::Event.find(:all, params: @params.merge(start_params)) }
        process_events(events)
        while events.next_page?
          events = with_retries { events.fetch_next_page }
          process_events(events)
        end

        broadcast(:shopify_events_changed, { shopify_shop_id: @shop.id })
      end
    end

    def start_params
      most_recent_event_id = @shop.data_events.maximum(:event_id)
      if most_recent_event_id
        { since_id: most_recent_event_id }
      else
        { created_at_min: Time.now.utc - 7.days }
      end
    end

    def process_events(event_list)
      attributes = event_list.map do |event|
        {
          event_id: event.id,
          author: event.author,
          arguments: event.arguments,
          body: event.body,
          description: event.description,
          path: event.path,
          verb: event.verb,
          subject_id: event.subject_id,
          shopify_created_at: event.created_at,
          account_id: @account.id,
          shopify_shop_id: @shop.id,
          created_at: @now,
          updated_at: @now,
        }
      end

      if !attributes.empty?
        ShopifyData::Event.insert_all!(attributes)
      end
    end
  end
end
