# frozen_string_literal: true

module ShopifyData
  # Invokes lighthouse using the crawler service to find all the requests made fo third party JS on a given storefront.
  class AppDetector
    include SemanticLogger::Loggable
    include Wisper::Publisher

    LIGHTHOUSE_CONFIG = {
      extends: "lighthouse:default",
      settings: {
        onlyAudits: %w[
          network-requests
        ],
      },
    }.freeze

    attr_reader :shopify_shop

    def initialize(shopify_shop)
      @shopify_shop = shopify_shop
    end

    def detect
      results = []

      Crawl::CrawlerClient.client.lighthouse(
        @shopify_shop.property,
        @shopify_shop.property.key_urls.map(&:url),
        lighthouse_config: LIGHTHOUSE_CONFIG,
        trace_context: { purpose: "shopify-app-detector" },
        on_result: proc do |result|
          result["lighthouse"]["audits"]["network-requests"]["details"]["items"].each do |request|
            next if request["resourceType"] != "Script"
            results << request["url"]
          end
        end,
        on_error: proc { |error_result| logger.warn("error encountered detecting apps with lighthouse", { error: error_result }) },
      )

      detect_from_request_urls(results)
      broadcast(:shopify_apps_changed, { shopify_shop_id: @shopify_shop.id, property_id: @shopify_shop.property_id })
    end

    def detect_from_request_urls(urls)
      @now = Time.now.utc

      detections = @shopify_shop.detected_apps.where(seen_last_time: true).each_with_object({}) do |detected_app, agg|
        agg[detected_app.subject_key] = {
          record: detected_app,
          seen: false,
          urls: [],
        }
      end

      urls.each do |url|
        subject_key, attributes = detect_subject_from_url(url)
        next unless subject_key

        if detections.key?(subject_key)
          detections[subject_key][:seen] = true
          detections[subject_key][:urls].push(url)
        else
          record = @shopify_shop.detected_apps.build(account_id: @shopify_shop.account_id, subject_key: subject_key, first_seen_at: @now)
          record.assign_attributes(attributes)
          detections[subject_key] = {
            seen: true,
            record: record,
            urls: [url],
          }
        end
      end

      seen_detections, unseen_detections = detections.values.partition { |detection| detection[:seen] }
      seen_detections.each do |detection|
        mark_as_seen(detection[:record], detection[:urls])
      end

      unseen_detections.each do |detection|
        mark_as_unseen(detection[:record])
      end
    end

    private

    def detect_subject_from_url(url)
      # TODO: check certified patterns on shopify app store apps

      # Check third-party-web for a hit
      entity = Infrastructure::ThirdPartyWeb.instance.entity(url)
      if entity && entity[:name] != "Shopify"
        name = entity[:name]
        return ["third-party-web-#{name}", { name: name }]
      end

      # As a last resport, check inferred domains for an app
      shopify_app = detect_inferred_shopify_app(url)
      if shopify_app
        return ["shopify-app-#{shopify_app.id}", { name: shopify_app.title, shopify_data_app_store_app_id: shopify_app.id }]
      end

      logger.info("Unrecognized URL for app detection", { url: url })
      [nil, nil]
    end

    def mark_as_seen(detected_app, urls)
      DetectedApp.transaction do
        first_time = detected_app.new_record?
        detected_app.last_seen_at = @now
        detected_app.seen_last_time = true
        detected_app.reasons = urls.sort.map { |url| "Request made to #{url}" }
        detected_app.save!

        if first_time
          shopify_shop.detected_app_change_events.create!(account_id: @shopify_shop.account_id, detected_app: detected_app, action: "detected", action_at: @now)
        end
      end
    end

    def mark_as_unseen(detected_app)
      DetectedApp.transaction do
        if detected_app.new_record?
          raise "Processing error: can't unsee a never before seen app"
        end
        detected_app.seen_last_time = false
        detected_app.save!

        shopify_shop.detected_app_change_events.create!(account_id: @shopify_shop.account_id, detected_app: detected_app, action: "no_longer_detected", action_at: @now)
      end
    end

    def detect_inferred_shopify_app(url)
      domain = Infrastructure::ThirdPartyWeb.instance.domain_from_origin_or_url(url)
      shopify_app_index[domain]
    end

    def shopify_app_index
      @shopify_app_index ||= ShopifyData::AppStoreApp.all.to_a.each_with_object({}) do |app, agg|
        app.inferred_domains.each do |domain|
          agg[domain] = app
        end
      end
    end
  end
end
