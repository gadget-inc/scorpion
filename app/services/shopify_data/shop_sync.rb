# frozen_string_literal: true

module ShopifyData

  # Knows how to fetch a Shop's representation from the API and save all the attributes we care about to the ShopifyShop record, and emit change events for some
  class ShopSync
    include ShopifyApiRetries
    include Wisper::Publisher

    to_string = ->(val) { val.to_s }
    SYNC_ATTRIBUTES = { cookie_consent_level: nil, country_code: nil, country_name: nil, currency: nil, customer_email: nil, domain: nil, enabled_presentment_currencies: nil, has_storefront: nil, latitude: to_string, longitude: to_string, money_format: nil, money_with_currency_format: nil, multi_location_enabled: nil, myshopify_domain: nil, password_enabled: nil, plan_display_name: nil, plan_name: nil, pre_launch_enabled: nil, requires_extra_payments_agreement: nil, setup_required: nil, source: nil, tax_shipping: nil, taxes_included: nil, timezone: nil, weight_unit: nil }.freeze

    CHANGE_TRACKED_ATTRIBUTES = %i[ domain has_storefront password_enabled plan_display_name setup_required country_name currency domain taxes_included weight_unit multi_location_enabled ].freeze

    attr_reader :shop

    def initialize(shop)
      @shop = shop
      @account = shop.account
      @now = Time.now.utc
    end

    def run
      @shop.with_shopify_session do
        shop_blob = with_retries { ShopifyAPI::Shop.current }
        new_attributes = attributes(shop_blob)
        @shop.assign_attributes(new_attributes)
        changes = change_attributes(@shop)

        ActiveRecord::Base.transaction do
          @shop.save!
          ShopChangeEvent.insert_all!(changes) if !changes.empty?
        end

        broadcast(:shopify_shop_changed, { shopify_shop_id: @shop.id, property_id: @shop.property_id })
      end
    end

    def attributes(shop_blob)
      SYNC_ATTRIBUTES.each_with_object({}) do |(attribute, transformer), agg|
        value = shop_blob.send(attribute)
        if transformer
          value = transformer.call(value)
        end
        agg[attribute] = value
      end
    end

    def change_attributes(shop_record)
      relevant_changes = shop_record.changes.symbolize_keys.slice(*CHANGE_TRACKED_ATTRIBUTES)
      relevant_changes.map do |attribute, (old_value, new_value)|
        {
          account_id: @account.id,
          shopify_shop_id: @shop.id,
          record_attribute: attribute,
          old_value: old_value,
          new_value: new_value,
          created_at: @now,
          updated_at: @now,
        }
      end
    end
  end
end
